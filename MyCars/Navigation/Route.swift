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
    case wash(carID: UUID)
    case insurance(carID: UUID)
    case unavailable(service: CarServiceType)
}

enum CarsRoute: Hashable {
    case addCar
}

enum StatsRoute: Hashable { case placeholder }

enum SettingsRoute: Hashable { case placeholder }
