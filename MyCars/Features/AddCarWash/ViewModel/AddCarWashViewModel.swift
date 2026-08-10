import Foundation
import Observation

@MainActor
@Observable
final class AddCarWashViewModel {
    private let carID: UUID
    private let repository: any ExpenseRepository
    private let onSaved: () -> Void

    var date = Date()
    var price = ""
    var mileage = ""
    private(set) var errorMessage: String?

    init(carID: UUID, repository: any ExpenseRepository, onSaved: @escaping () -> Void) {
        self.carID = carID
        self.repository = repository
        self.onSaved = onSaved
    }

    func save() {
        do {
            let currentMileage = try repository.currentMileage(for: carID)
            let parsedMileage = mileage.isEmpty ? nil : try FormValidation.integer(mileage, field: "Пробіг", minimum: currentMileage)
            try repository.addWash(to: carID, price: try FormValidation.decimal(price, field: "Вартість", minimum: 0.01), mileage: parsedMileage, date: date)
            onSaved()
        } catch { errorMessage = error.localizedDescription }
    }

    func dismissError() { errorMessage = nil }
}
