import Foundation
import Observation

@MainActor
@Observable
final class AddRefuelViewModel {
    private let carID: UUID
    private let repository: any ExpenseRepository
    private let onSaved: () -> Void

    var date = Date()
    var mileage = ""
    var amount = ""
    var pricePerUnit = ""
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
            try repository.addRefill(
                to: carID,
                mileage: try FormValidation.integer(mileage, field: "Пробіг", minimum: currentMileage),
                amount: try FormValidation.decimal(amount, field: "Кількість палива", minimum: 0.01),
                pricePerUnit: try FormValidation.decimal(pricePerUnit, field: "Ціна за одиницю", minimum: 0.01),
                date: date
            )
            onSaved()
        } catch { errorMessage = error.localizedDescription }
    }

    func dismissError() { errorMessage = nil }
}
