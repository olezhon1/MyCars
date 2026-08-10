import Foundation
import Observation

@MainActor
@Observable
final class AddMaintenanceViewModel {
    private let carID: UUID
    private let repository: any ExpenseRepository
    private let onSaved: () -> Void

    var title = ""
    var price = ""
    var date = Date()
    var mileage = ""
    var notes = ""
    private(set) var errorMessage: String?

    init(carID: UUID, repository: any ExpenseRepository, onSaved: @escaping () -> Void) {
        self.carID = carID
        self.repository = repository
        self.onSaved = onSaved
    }

    func save() {
        do {
            try repository.addMaintenance(
                to: carID,
                title: try FormValidation.required(title, field: "Назва"),
                price: try FormValidation.decimal(price, field: "Вартість", minimum: 0.01),
                mileage: try FormValidation.integer(mileage, field: "Пробіг"),
                date: date,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes
            )
            onSaved()
        } catch { errorMessage = error.localizedDescription }
    }

    func dismissError() { errorMessage = nil }
}
