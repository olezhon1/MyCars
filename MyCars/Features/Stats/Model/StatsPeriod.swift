//
//  StatsPeriod.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 25.06.2026.
//

import Foundation

enum StatsPeriod: CaseIterable {
    case month, halfYear, year, allTime

    var title: String {
        switch self {
        case .month:    return "Місяць"
        case .halfYear: return "Пів року"
        case .year:     return "Рік"
        case .allTime:  return "Весь час"
        }
    }

    var startDate: Date {
        let calendar = Calendar.current
        switch self {
        case .month: return calendar.date(byAdding: .month, value: -1, to: .now) ?? .distantPast
        case .halfYear: return calendar.date(byAdding: .month, value: -6, to: .now) ?? .distantPast
        case .year: return calendar.date(byAdding: .year, value: -1, to: .now) ?? .distantPast
        case .allTime: return .distantPast
        }
    }
}
