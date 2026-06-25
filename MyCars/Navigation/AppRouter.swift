//
//  AppRouter.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 05.06.2026.
//

// Navigation/AppRouter.swift
import SwiftUI

@Observable
final class AppRouter {
    var selectedTab: AppTab = .home
    
    var homePath = NavigationPath()
    var carsPath = NavigationPath()
    var statsPath = NavigationPath()
    var settingsPath = NavigationPath()
    
    func push(_ route: some Route) {
        switch selectedTab {
        case .home: homePath.append(route)
        case .myCars: carsPath.append(route)
        case .stats: statsPath.append(route)
        case .settings: settingsPath.append(route)
        }
    }
    
    func pop() {
        switch selectedTab {
        case .home:     if !homePath.isEmpty { homePath.removeLast() }
        case .myCars:   if !carsPath.isEmpty { carsPath.removeLast() }
        case .stats:    if !statsPath.isEmpty { statsPath.removeLast() }
        case .settings: if !settingsPath.isEmpty { settingsPath.removeLast() }
        }
    }
    
    func popToRoot() {
        switch selectedTab {
        case .home:     homePath.removeLast(homePath.count)
        case .myCars:   carsPath.removeLast(carsPath.count)
        case .stats:    statsPath.removeLast(statsPath.count)
        case .settings: settingsPath.removeLast(settingsPath.count)
        }
    }
    
    func switchTab(_ tab: AppTab) {
        selectedTab = tab
    }
}
