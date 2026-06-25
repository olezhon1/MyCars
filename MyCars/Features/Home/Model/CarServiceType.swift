//
//  CarServiceType.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 18.06.2026.
//

import SwiftUI
enum CarServiceType: CaseIterable, Identifiable {

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
        default:
            return nil
        }
    }
    
    var route: HomeRoute {
        switch self {
        case .fuel: return .fuel
        case .maintenance: return .maintenance
        case .wash: return .wash
        case .tireService: return .tireService
        case .repair: return .repair
        case .otherExpenses: return .otherExpenses
        case .insurance: return .insurance
        case .tuning: return .tuning
        }
    }
}
