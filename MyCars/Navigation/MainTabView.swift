//
//  MainTabView.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 06.06.2026.
//

import SwiftUI

struct MainTabView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            
            NavigationStack(path: $router.homePath) {
                HomeView(viewModel: HomeViewModel(router: router))
                    .navigationDestination(for: HomeRoute.self) { route in
                        route.view(router: router)
                    }
            }
            .tabItem {
                Image(AppTab.home.icon)
                Text(AppTab.home.rawValue)
            }
            .tag(AppTab.home)
            
            NavigationStack(path: $router.carsPath) {
                MyCarsView(viewModel: MyCarsViewModel(router: router))
                .navigationDestination(for: CarsRoute.self) { route in
                    route.view(router: router)
                }
            }
            .tabItem {
                Image(AppTab.myCars.icon)
                Text(AppTab.myCars.rawValue)
            }
            .tag(AppTab.myCars)
            
            NavigationStack(path: $router.statsPath) {
                StatsView(viewModel: StatsViewModel(router: router))
                .navigationDestination(for: StatsRoute.self) { route in
                    route.view(router: router)
                }
            }
            .tabItem {
                Image(AppTab.stats.icon)
                Text(AppTab.stats.rawValue)
            }
            .tag(AppTab.stats)
            
            NavigationStack(path: $router.settingsPath) {
                HomeView(viewModel: HomeViewModel(router: router))
                    .navigationDestination(for: SettingsRoute.self) { route in
                        route.view(router: router)
                    }
            }
            .tabItem {
                Image(AppTab.settings.icon)
                Text(AppTab.settings.rawValue)
            }
            .tag(AppTab.settings)
        }
        
//
//        .sheet(item: $router.sheet) { sheet in
//            switch sheet {
//            case .addCar:
//                HomeView()
//            case .editCar(let id):
//                HomeView()
//            }
//        }
    }
}
