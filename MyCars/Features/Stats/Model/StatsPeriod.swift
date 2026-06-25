//
//  StatsPeriod.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 25.06.2026.
//

enum StatsPeriod: CaseIterable {
    case month, halfYear, year, allTime

    var title: String {
        switch self {
        case .month:    return "Місяць"
        case .halfYear: return "Пів року"
        case .year:     return "Рік"
        case .allTime:  return "Все час"
        }
    }
}
