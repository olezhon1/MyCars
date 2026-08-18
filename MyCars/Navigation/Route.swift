//
//  Route.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 05.06.2026.
//

import Foundation

// REVIEW: Routes contain stable identifiers only; they no longer construct views or retain SwiftData models.
enum HomeRoute: Hashable {
    case fuel(carID: UUID)
    case maintenance(carID: UUID)
    case tuning(carID: UUID)
    case tireService(carID: UUID)
    case repair(carID: UUID)
    case otherExpenses(carID: UUID)
    case wash(carID: UUID)
    case insurance(carID: UUID)
    case unavailable(service: CarServiceType)
}

enum CarsRoute: Hashable {
    case addCar
}

enum StatsRoute: Hashable {
    case fuel(car: Car)
    case maintenance(car: Car)
    case tuning(car: Car)
    case tireService(car: Car)
    case repair(car: Car)
    case otherExpenses(car: Car)
    case wash(car: Car)
    case insurance(car: Car)
    case unavailable(service: CarServiceType)
}

enum SettingsRoute: Hashable { case placeholder }
