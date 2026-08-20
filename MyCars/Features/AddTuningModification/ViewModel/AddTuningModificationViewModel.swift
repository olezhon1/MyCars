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

        if let currentMileage = try? repository.currentMileage(for: carID) {
            mileage = String(currentMileage)
        }
    }

    func save() {
        do {
            let currentMileage = try repository.currentMileage(for: carID)
            try repository.addTuningModification(
                to: carID,
                name: try FormValidation.required(name, field: "common.title"),
                price: try FormValidation.decimal(price, field: "common.cost", minimum: 0.01),
                date: date,
                mileage: try FormValidation.integer(mileage, field: "car.field.mileage", minimum: currentMileage),
            )
            onSaved()
        } catch { errorMessage = error.localizedDescription }
    }

    func dismissError() { errorMessage = nil }
}
