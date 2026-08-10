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
            selection: container.carSelection
        ))
    }

    var body: some View {
        TabView(selection: $router.selectedTab) {
            NavigationStack(path: $router.homePath) {
                HomeView(viewModel: homeViewModel)
                    .navigationDestination(for: HomeRoute.self, destination: homeDestination)
            }
            .tabItem { Label(AppTab.home.rawValue, image: AppTab.home.icon) }
            .tag(AppTab.home)

            NavigationStack(path: $router.carsPath) {
                MyCarsView(viewModel: carsViewModel)
                    .navigationDestination(for: CarsRoute.self, destination: carsDestination)
            }
            .tabItem { Label(AppTab.myCars.rawValue, image: AppTab.myCars.icon) }
            .tag(AppTab.myCars)

            NavigationStack(path: $router.statsPath) {
                StatsView(viewModel: statsViewModel)
            }
            .tabItem { Label(AppTab.stats.rawValue, image: AppTab.stats.icon) }
            .tag(AppTab.stats)

            NavigationStack {
                ContentUnavailableView("Налаштування", systemImage: "gear", description: Text("Розділ у розробці"))
            }
            .tabItem { Label(AppTab.settings.rawValue, image: AppTab.settings.icon) }
            .tag(AppTab.settings)
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
}
