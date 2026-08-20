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
    private let carID: UUID
    private let repository: any CarRepository
    private let service: CarServiceType

    var selectedPeriod: StatsPeriod = .halfYear {
        didSet {
            load()
        }
    }

    private(set) var expenses: [ExpensePoint] = []
    private(set) var expenseSections: [ExpenseMonthSection] = []
    private(set) var selectedMonth: Date?
    private(set) var errorMessage: String?

    init(carID: UUID, repository: any CarRepository, service: CarServiceType) {
        self.carID = carID
        self.repository = repository
        self.service = service
    }

    var hasData: Bool { !expenseSections.isEmpty }
    var serviceTitle: String { service.title }

    func load() {
        do {
            let selectedCar = try repository.car(id: carID)
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
            errorMessage = nil
        } catch {
            expenses = []
            expenseSections = []
            errorMessage = error.localizedDescription
        }

        let calendar = Calendar.current
        selectedMonth = expenses.first {
            calendar.isDate($0.month, equalTo: .now, toGranularity: .month)
        }?.month ?? expenses.last?.month
    }

    func selectMonth(_ month: Date) {
        selectedMonth = month
    }

    func dismissError() { errorMessage = nil }
}
