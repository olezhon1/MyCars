import SwiftUI

struct MainTabView: View {
    @Bindable private var router: AppRouter
    private let container: AppContainer

    // REVIEW: Root ViewModels are owned by @State, so SwiftUI body recalculation does not reset screen state.
    @State private var homeViewModel: HomeViewModel
    @State private var carsViewModel: MyCarsViewModel
    @State private var statsViewModel: StatsViewModel

    @MainActor
    init(router: AppRouter, container: AppContainer) {
        self.router = router
        self.container = container
        _homeViewModel = State(initialValue: HomeViewModel(
            repository: container.carRepository,
            selection: container.carSelection,
            onRoute: { router.push($0) }
        ))
        _carsViewModel = State(initialValue: MyCarsViewModel(
            repository: container.carRepository,
            selection: container.carSelection,
            onAddCar: { router.push(CarsRoute.addCar) }
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
                ContentUnavailableView("Налаштування", systemImage: "gear", description: Text("Розділ у розробці"))
            }
            .tabItem { tabLabel(for: .settings) }
            .tag(AppTab.settings)
        }
        .tint(Color("primary"))
    }

    private func tabLabel(for tab: AppTab) -> some View {
        Label {
            Text(tab.rawValue)
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
            AddRefuelView(viewModel: AddRefuelViewModel(carID: carID, repository: container.expenseRepository, onSaved: router.pop))
        case .wash(let carID):
            AddCarWashView(viewModel: AddCarWashViewModel(carID: carID, repository: container.expenseRepository, onSaved: router.pop))
        case .insurance(let carID):
            AddInsuranceView(viewModel: AddInsuranceViewModel(carID: carID, repository: container.expenseRepository, onSaved: router.pop))
        case .maintenance(let carID):
            AddMaintenanceView(viewModel: AddMaintenanceViewModel(carID: carID, repository: container.expenseRepository, onSaved: router.pop))
        case .tuning(let carID):
            AddTuningModificationView(viewModel: AddTuningModificationViewModel(carID: carID, repository: container.expenseRepository, onSaved: router.pop))
        case .tireService(let carID):
            AddTireServiceView(viewModel: AddTireServiceViewModel(carID: carID, repository: container.expenseRepository, onSaved: router.pop))
        case .repair(let carID):
            AddRepairView(viewModel: AddRepairViewModel(carID: carID, repository: container.expenseRepository, onSaved: router.pop))
        case .otherExpenses(let carID):
            AddOtherExpenseView(viewModel: AddOtherExpenseViewModel(carID: carID, repository: container.expenseRepository, onSaved: router.pop))
        case .unavailable(let service):
            ContentUnavailableView(service.title, systemImage: "wrench.and.screwdriver", description: Text("Ця функція ще в розробці"))
        }
    }

    @ViewBuilder
    private func carsDestination(_ route: CarsRoute) -> some View {
        switch route {
        case .addCar:
            AddCarView(viewModel: AddCarViewModel(repository: container.carRepository, onSaved: router.pop))
        }
    }
    
    @ViewBuilder
    private func statsDestination(_ route: StatsRoute) -> some View {
        switch route {
        case .fuel(let car):
            StatsDetailView(viewModel: StatsDetailViewModel(selectedCar: car, service: .fuel))
        case .wash(let car):
            StatsDetailView(viewModel: StatsDetailViewModel(selectedCar: car, service: .wash))
        case .insurance(let car):
            StatsDetailView(viewModel: StatsDetailViewModel(selectedCar: car, service: .insurance))
        case .maintenance(let car):
            StatsDetailView(viewModel: StatsDetailViewModel(selectedCar: car, service: .maintenance))
        case .tuning(let car):
            StatsDetailView(viewModel: StatsDetailViewModel(selectedCar: car, service: .tuning))
        case .tireService(let car):
            StatsDetailView(viewModel: StatsDetailViewModel(selectedCar: car, service: .tireService))
        case .repair(let car):
            StatsDetailView(viewModel: StatsDetailViewModel(selectedCar: car, service: .repair))
        case .otherExpenses(let car):
            StatsDetailView(viewModel: StatsDetailViewModel(selectedCar: car, service: .otherExpenses))
        case .unavailable(let service):
            ContentUnavailableView(service.title, systemImage: "wrench.and.screwdriver", description: Text("Ця функція ще в розробці"))
        }
    }
}
