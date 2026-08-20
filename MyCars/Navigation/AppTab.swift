//
//  AppTab.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 06.06.2026.
//

enum AppTab: String, CaseIterable {
    case home    = "tab.home"
    case myCars = "tab.myCars"
    case stats    = "tab.statistics"
    case settings = "settings.title"
    
    var icon: String {
        switch self {
        case .home:    return "tab_home"
        case .myCars: return "tab_cars"
        case .stats:    return "tab_stats"
        case .settings: return "tab_settings"
        }
    }
}
