import SwiftUI

struct MainTabView: View {
    @Bindable private var router: AppRouter
    private let container: AppContainer

    // REVIEW: Root ViewModels are owned by @State, so SwiftUI body recalculation does not reset screen state.
    @State private var homeViewModel: HomeViewModel
    @State private var carsViewModel: MyCarsViewModel
    @State private var statsViewModel: StatsViewModel
    @State private var settings: AppSettings

    @MainActor
    init(router: AppRouter, container: AppContainer) {
        self.router = router
        self.container = container
        _settings = State(initialValue: container.settings)
#if DEBUG
        let createDebugCars: (() throws -> UUID?)? = {
            try container.debugCarSeeder.seed()
        }
#else
        let createDebugCars: (() throws -> UUID?)? = nil
#endif
        _homeViewModel = State(initialValue: HomeViewModel(
            repository: container.carRepository,
            selection: container.carSelection,
            onRoute: { router.push($0) }
        ))
        _carsViewModel = State(initialValue: MyCarsViewModel(
            repository: container.carRepository,
            selection: container.carSelection,
            onAddCar: { router.push(CarsRoute.addCar) },
            onEditCar: { router.push(CarsRoute.editCar(carID: $0)) },
            onDataChanged: { Task { try? await container.reminderService.synchronize() } },
            onCreateDebugCars: createDebugCars
        ))
        _statsViewModel = State(initialValue: StatsViewModel(
            repository: container.carRepository,
            selection: container.carSelection,
            onRoute: { router.push($0) }
        ))
    }

    var body: some View {
        TabView(selection: $router.selectedTab) {
            NavigationStack(path: $router.homePath) {
                HomeView(viewModel: homeViewModel)
                    .navigationDestination(for: HomeRoute.self, destination: homeDestination)
            }
            .tabItem { tabLabel(for: .home) }
            .tag(AppTab.home)

            NavigationStack(path: $router.carsPath) {
                MyCarsView(viewModel: carsViewModel)
                    .navigationDestination(for: CarsRoute.self, destination: carsDestination)
            }
            .tabItem { tabLabel(for: .myCars) }
            .tag(AppTab.myCars)

            NavigationStack(path: $router.statsPath) {
                StatsView(viewModel: statsViewModel)
                    .navigationDestination(for: StatsRoute.self, destination: statsDestination)
            }
            .tabItem { tabLabel(for: .stats) }
            .tag(AppTab.stats)

            NavigationStack {
                SettingsView(settings: settings, reminderService: container.reminderService)
            }
            .tabItem { tabLabel(for: .settings) }
            .tag(AppTab.settings)
        }
        .tint(Color("primary"))
        .environment(\.locale, settings.language.locale)
    }

    private func tabLabel(for tab: AppTab) -> some View {
        Label {
            Text(L10n.text(tab.rawValue))
        } icon: {
            if let icon = UIImage(named: tab.icon)?.withRenderingMode(.alwaysTemplate) {
                Image(uiImage: icon)
            }
        }
    }

    @ViewBuilder
    private func homeDestination(_ route: HomeRoute) -> some View {
        switch route {
        case .fuel(let carID):
            AddRefuelView(viewModel: AddRefuelViewModel(carID: carID, repository: container.expenseRepository, onSaved: didSaveExpense))
        case .wash(let carID):
            AddCarWashView(viewModel: AddCarWashViewModel(carID: carID, repository: container.expenseRepository, onSaved: didSaveExpense))
        case .insurance(let carID):
            AddInsuranceView(viewModel: AddInsuranceViewModel(carID: carID, repository: container.expenseRepository, onSaved: didSaveExpense))
        case .maintenance(let carID):
            AddMaintenanceView(viewModel: AddMaintenanceViewModel(carID: carID, repository: container.expenseRepository, onSaved: didSaveExpense))
        case .tuning(let carID):
            AddTuningModificationView(viewModel: AddTuningModificationViewModel(carID: carID, repository: container.expenseRepository, onSaved: didSaveExpense))
        case .tireService(let carID):
            AddTireServiceView(viewModel: AddTireServiceViewModel(carID: carID, repository: container.expenseRepository, onSaved: didSaveExpense))
        case .repair(let carID):
            AddRepairView(viewModel: AddRepairViewModel(carID: carID, repository: container.expenseRepository, onSaved: didSaveExpense))
        case .otherExpenses(let carID):
            AddOtherExpenseView(viewModel: AddOtherExpenseViewModel(carID: carID, repository: container.expenseRepository, onSaved: didSaveExpense))
        case .unavailable(let service):
            ContentUnavailableView(service.title, systemImage: "wrench.and.screwdriver", description: Text("common.comingSoon"))
        }
    }

    @ViewBuilder
    private func carsDestination(_ route: CarsRoute) -> some View {
        switch route {
        case .addCar:
            AddCarView(viewModel: AddCarViewModel(repository: container.carRepository, onSaved: didSaveCar))
        case .editCar(let carID):
            AddCarView(viewModel: AddCarViewModel(carID: carID, repository: container.carRepository, onSaved: didSaveCar))
        }
    }

    private func didSaveCar(_ carID: UUID) {
        container.carSelection.select(carID)
        router.pop()
        Task { try? await container.reminderService.synchronize() }
    }

    private func didSaveExpense() {
        router.pop()
        Task { try? await container.reminderService.synchronize() }
    }
    
    @ViewBuilder
    private func statsDestination(_ route: StatsRoute) -> some View {
        switch route {
        case .fuel(let carID):
            statsDetail(carID: carID, service: .fuel)
        case .wash(let carID):
            statsDetail(carID: carID, service: .wash)
        case .insurance(let carID):
            statsDetail(carID: carID, service: .insurance)
        case .maintenance(let carID):
            statsDetail(carID: carID, service: .maintenance)
        case .tuning(let carID):
            statsDetail(carID: carID, service: .tuning)
        case .tireService(let carID):
            statsDetail(carID: carID, service: .tireService)
        case .repair(let carID):
            statsDetail(carID: carID, service: .repair)
        case .otherExpenses(let carID):
            statsDetail(carID: carID, service: .otherExpenses)
        case .unavailable(let service):
            ContentUnavailableView(service.title, systemImage: "wrench.and.screwdriver", description: Text("common.comingSoon"))
        }
    }

    private func statsDetail(carID: UUID, service: CarServiceType) -> some View {
        StatsDetailView(
            viewModel: StatsDetailViewModel(
                carID: carID,
                repository: container.carRepository,
                service: service
            )
        )
    }
}
