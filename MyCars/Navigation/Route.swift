//
//  Route.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 05.06.2026.
//

import Foundation
import SwiftUI

protocol Route: Hashable {
    associatedtype Destination: View
    @ViewBuilder func view(router: AppRouter) -> Destination
}

enum HomeRoute: Route {
    case home
    case fuel
    case maintenance
    case wash
    case tireService
    case repair
    case otherExpenses
    case insurance
    case tuning
    
    @ViewBuilder
    func view(router: AppRouter) -> some View {
        switch self {
        case .home:
            HomeView(viewModel: HomeViewModel(router: router))
        default:
            EmptyView()
        }
    }
}

enum CarsRoute: Route {
    case myCars
    case addCar
    
    @ViewBuilder
    func view(router: AppRouter) -> some View {
        switch self {
        case .myCars:
            MyCarsView(viewModel: MyCarsViewModel(router: router))
        case .addCar:
            AddCarView(viewModel: AddCarViewModel(router: router))
        }
    }
}

enum StatsRoute: Route {
    
    @ViewBuilder
    func view(router: AppRouter) -> some View {

    }
}

enum SettingsRoute: Route {
    
    @ViewBuilder
    func view(router: AppRouter) -> some View {
        
    }
}

