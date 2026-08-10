import Foundation
import Observation

@MainActor
@Observable
final class AddCarViewModel {
    private let repository: any CarRepository
    private let onSaved: () -> Void

    var selectedImageData: Data?
    var brand = ""
    var model = ""
    var year = ""
    var purchasePrice = ""
    var purchaseMileage = ""
    var purchaseDate = Date.now
    var powertrain: PowertrainType = .petrol
    var energyCapacity = ""
    private(set) var errorMessage: String?

    init(repository: any CarRepository, onSaved: @escaping () -> Void) {
        self.repository = repository
        self.onSaved = onSaved
    }

    func save() {
        do {
            let car = Car(
                brand: try FormValidation.required(brand, field: "Марка"),
                model: try FormValidation.required(model, field: "Модель"),
                year: try FormValidation.integer(year, field: "Рік", minimum: 1886),
                purchasePrice: try FormValidation.decimal(purchasePrice, field: "Ціна купівлі"),
                purchaseMileage: try FormValidation.integer(purchaseMileage, field: "Пробіг"),
                purchaseDate: purchaseDate,
                powertrain: powertrain,
                energyCapacity: try FormValidation.decimal(energyCapacity, field: "Об’єм / ємність"),
                imageData: selectedImageData
            )
            try repository.add(car)
            onSaved()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func dismissError() { errorMessage = nil }
}
