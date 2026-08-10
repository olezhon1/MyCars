//
//  AddTuningModificationViewModel.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 10.08.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class AddTuningModificationViewModel {
    private let carID: UUID
    private let repository: any ExpenseRepository
    private let onSaved: () -> Void

    var name = ""
    var price = ""
    var date = Date()
    var mileage = ""
    private(set) var errorMessage: String?

    init(carID: UUID, repository: any ExpenseRepository, onSaved: @escaping () -> Void) {
        self.carID = carID
        self.repository = repository
        self.onSaved = onSaved
    }

    func save() {
        do {
            try repository.addTuningModification(
                to: carID,
                name: try FormValidation.required(name, field: "Назва"),
                price: try FormValidation.decimal(price, field: "Вартість", minimum: 0.01),
                date: date,
                mileage: try FormValidation.integer(mileage, field: "Пробіг"),
            )
            onSaved()
        } catch { errorMessage = error.localizedDescription }
    }

    func dismissError() { errorMessage = nil }
}
