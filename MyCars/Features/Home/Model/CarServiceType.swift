//
//  CarServiceType.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 18.06.2026.
//

import SwiftUI
enum CarServiceType: CaseIterable, Identifiable, Hashable {
    
    case fuel
    case maintenance
    case wash
    case tireService
    case repair
    case otherExpenses
    case insurance
    case tuning
    
    var id: String { title }
    
    var title: String {
        switch self {
        case .fuel:
            return "Заправка"
        case .maintenance:
            return "ТО"
        case .wash:
            return "Мийка"
        case .tireService:
            return "Шиномонтаж"
        case .repair:
            return "Ремонт"
        case .otherExpenses:
            return "Інші витрати"
        case .insurance:
            return "Страхування"
        case .tuning:
            return "Тюнінг"
        }
    }
    
    var color: Color {
        switch self {
        case .fuel:          return Color("fuel_stats")
        case .repair:        return Color("repair_stats")
        case .wash:          return Color("water_stats")
        case .tuning:        return Color("tuning_stats")
        case .insurance:     return Color("insurance_stats")
        case .maintenance:   return Color("maintenance_stats")
        case .tireService:   return Color("tire_stats")
        case .otherExpenses: return Color("other_stats")
        }
    }
    
    var image: String? {
        switch self {
        case .fuel:
            return "fuel"
        case .maintenance:
            return "maintenance"
        case .wash:
            return "wash"
        case .tuning:
            return "tuning"
        case .insurance:
            return "insurance"
        case .tireService:
            return "tire_service"
        case .repair:
            return "repair"
        case .otherExpenses:
            return "other_expense"
        }
    }
    
    func route(for carID: UUID) -> HomeRoute {
        switch self {
        case .fuel: return .fuel(carID: carID)
        case .maintenance: return .maintenance(carID: carID)
        case .wash: return .wash(carID: carID)
        case .insurance: return .insurance(carID: carID)
        case .tuning: return .tuning(carID: carID)
        case .tireService: return .tireService(carID: carID)
        case .repair: return .repair(carID: carID)
        case .otherExpenses: return .otherExpenses(carID: carID)
        }
    }
    
    func statsRoute(for carID: UUID) -> StatsRoute {
        switch self {
        case .fuel: return .fuel(carID: carID)
        case .maintenance: return .maintenance(carID: carID)
        case .wash: return .wash(carID: carID)
        case .insurance: return .insurance(carID: carID)
        case .tuning: return .tuning(carID: carID)
        case .tireService: return .tireService(carID: carID)
        case .repair: return .repair(carID: carID)
        case .otherExpenses: return .otherExpenses(carID: carID)
        }
    }

}
