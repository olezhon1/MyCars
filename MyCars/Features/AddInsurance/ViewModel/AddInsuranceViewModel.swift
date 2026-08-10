import Foundation
import Observation

@MainActor
@Observable
final class AddInsuranceViewModel {
    private let carID: UUID
    private let repository: any ExpenseRepository
    private let onSaved: () -> Void

    var type: InsuranceType = .none
    var policyNumber = ""
    var companyName = ""
    var startDate = Date()
    var endDate = Date()
    var price = ""
    private(set) var errorMessage: String?

    init(carID: UUID, repository: any ExpenseRepository, onSaved: @escaping () -> Void) {
        self.carID = carID
        self.repository = repository
        self.onSaved = onSaved
    }

    func save() {
        do {
            guard type != .none else { throw ValidationError.message("Оберіть тип страхування.") }
            guard endDate >= startDate else { throw ValidationError.message("Дата завершення не може бути раніше дати початку.") }
            try repository.addInsurance(
                to: carID,
                type: type,
                policyNumber: try FormValidation.required(policyNumber, field: "Номер полісу"),
                companyName: try FormValidation.required(companyName, field: "Страхова компанія"),
                startDate: startDate,
                endDate: endDate,
                price: try FormValidation.decimal(price, field: "Вартість", minimum: 0.01)
            )
            onSaved()
        } catch { errorMessage = error.localizedDescription }
    }

    func dismissError() { errorMessage = nil }
}
