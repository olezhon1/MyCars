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
        case .month:    return L10n.text("statistics.period.month")
        case .halfYear: return L10n.text("statistics.period.halfYear")
        case .year:     return L10n.text("common.year")
        case .allTime:  return L10n.text("statistics.period.allTime")
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
