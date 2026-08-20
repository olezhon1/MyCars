import Foundation
import Observation

@MainActor
@Observable
final class AddCarViewModel {
    private let repository: any CarRepository
    private let carID: UUID?
    private let onSaved: (UUID) -> Void

    var selectedImageData: Data?
    var brand = ""
    var model = ""
    var year = ""
    var purchasePrice = ""
    var purchaseMileage = ""
    var purchaseDate = Date.now
    var energyCapacity = ""
    private(set) var errorMessage: String?

    var isEditing: Bool { carID != nil }
    var navigationTitle: String { L10n.text(isEditing ? "car.edit.title" : "car.add.title") }
    var saveButtonTitle: String { L10n.text(isEditing ? "common.saveChanges" : "common.save") }

    init(carID: UUID? = nil, repository: any CarRepository, onSaved: @escaping (UUID) -> Void) {
        self.carID = carID
        self.repository = repository
        self.onSaved = onSaved
        loadCarIfNeeded()
    }

    func save() {
        do {
            let validatedBrand = try FormValidation.required(brand, field: "car.field.brand")
            let validatedModel = try FormValidation.required(model, field: "car.field.model")
            let validatedYear = try FormValidation.integer(year, field: "common.year", minimum: 1886)
            let validatedPurchasePrice = try FormValidation.decimal(purchasePrice, field: "car.field.purchasePrice")
            let validatedPurchaseMileage = try FormValidation.integer(purchaseMileage, field: "car.field.mileage")
            let validatedEnergyCapacity = try FormValidation.decimal(energyCapacity, field: "car.field.energyCapacity")
            let data = CarData(
                brand: validatedBrand,
                model: validatedModel,
                year: validatedYear,
                purchasePrice: validatedPurchasePrice,
                purchaseMileage: validatedPurchaseMileage,
                purchaseDate: purchaseDate,
                energyCapacity: validatedEnergyCapacity,
                imageData: selectedImageData
            )

            if let carID {
                try repository.update(carID: carID, with: data)
                onSaved(carID)
            } else {
                onSaved(try repository.add(data))
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func dismissError() { errorMessage = nil }

    private func loadCarIfNeeded() {
        guard let carID else { return }

        do {
            guard let car = try repository.car(id: carID) else {
                throw RepositoryError.carNotFound
            }
            selectedImageData = car.imageData
            brand = car.brand
            model = car.model
            year = String(car.year)
            purchasePrice = String(car.purchasePrice)
            purchaseMileage = String(car.purchaseMileage)
            purchaseDate = car.purchaseDate
            energyCapacity = String(car.energyCapacity)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
