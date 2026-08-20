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
            guard type != .none else { throw ValidationError.message(L10n.text("insurance.validation.typeRequired")) }
            guard endDate >= startDate else {
                throw ValidationError.message(L10n.text("insurance.validation.endDate"))
            }
            try repository.addInsurance(
                to: carID,
                type: type,
                policyNumber: try FormValidation.required(policyNumber, field: "insurance.field.policyNumber"),
                companyName: try FormValidation.required(companyName, field: "insurance.field.company"),
                startDate: startDate,
                endDate: endDate,
                price: try FormValidation.decimal(price, field: "common.cost", minimum: 0.01)
            )
            onSaved()
        } catch { errorMessage = error.localizedDescription }
    }

    func dismissError() { errorMessage = nil }
}
