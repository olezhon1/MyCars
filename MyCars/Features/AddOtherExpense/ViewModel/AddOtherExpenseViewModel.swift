import Foundation
import Observation

@MainActor
@Observable
final class AddOtherExpenseViewModel {
    private let carID: UUID
    private let repository: any ExpenseRepository
    private let onSaved: () -> Void

    var title = ""
    var price = ""
    var mileage = ""
    var date = Date.now
    var notes = ""
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
            try repository.addOtherExpense(
                to: carID,
                title: try FormValidation.required(title, field: "Назва"),
                price: try FormValidation.decimal(price, field: "Вартість", minimum: 0.01),
                mileage: try optionalMileage(minimum: currentMileage),
                date: date,
                notes: normalizedNotes
            )
            onSaved()
        } catch { errorMessage = error.localizedDescription }
    }

    func dismissError() { errorMessage = nil }

    private func optionalMileage(minimum: Int) throws -> Int? {
        let value = mileage.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : try FormValidation.integer(value, field: "Пробіг", minimum: minimum)
    }

    private var normalizedNotes: String? {
        let value = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
