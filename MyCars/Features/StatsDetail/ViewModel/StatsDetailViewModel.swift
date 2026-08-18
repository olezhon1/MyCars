//
//  StatsDetailViewModel.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 11.08.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class StatsDetailViewModel {
    private let selectedCar: Car?
    private let service: CarServiceType

    var selectedPeriod: StatsPeriod = .halfYear {
        didSet {
            load()
        }
    }

    private(set) var expenses: [ExpensePoint] = [.empty]
    private(set) var expenseSections: [ExpenseMonthSection] = []
    private(set) var selectedMonth: Date?

    init(selectedCar: Car?, service: CarServiceType) {
        self.selectedCar = selectedCar
        self.service = service
    }

    func load() {
        expenses = PresentationMapper.expensesForService(
            for: selectedCar,
            period: selectedPeriod,
            service: service
        )
        expenseSections = PresentationMapper.expenseHistory(
            for: selectedCar,
            period: selectedPeriod,
            service: service
        )

        let calendar = Calendar.current
        selectedMonth = expenses.first {
            calendar.isDate($0.month, equalTo: .now, toGranularity: .month)
        }?.month ?? expenses.last?.month
    }

    func selectMonth(_ month: Date) {
        selectedMonth = month
    }
}
