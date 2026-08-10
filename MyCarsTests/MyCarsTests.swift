import Foundation
import SwiftData
import Testing
@testable import MyCars

@MainActor
struct MyCarsTests {
    @Test func formValidationAcceptsCommaDecimalSeparator() throws {
        #expect(try FormValidation.decimal("12,5", field: "Ціна") == 12.5)
    }

    @Test func formValidationRejectsEmptyRequiredValue() {
        #expect(throws: ValidationError.self) {
            try FormValidation.required("   ", field: "Марка")
        }
    }

    @Test func selectionReconcilesDeletedCar() {
        let suiteName = "CarSelectionStoreTests-\(UUID())"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = CarSelectionStore(defaults: defaults)
        let first = makeCar(brand: "A")
        let second = makeCar(brand: "B")

        store.select(first.id)
        store.reconcile(with: [second])

        #expect(store.selectedCarID == second.id)
    }

    @Test func repositoryLinksExpenseToCar() throws {
        let schema = Schema([Car.self, Insurance.self, TuningModification.self, CarWash.self, Maintenance.self, EnergyRefill.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let repository = SwiftDataRepository(context: container.mainContext)
        let car = makeCar(brand: "Dacia")
        try repository.add(car)

        try repository.addWash(to: car.id, price: 300, mileage: 10_000, date: .now)

        let savedCar = try #require(try repository.car(id: car.id))
        #expect(savedCar.washes.count == 1)
        #expect(savedCar.washes.first?.car?.id == car.id)
    }

    @Test func addCarViewModelDoesNotCloseOnInvalidInput() {
        let repository = CarRepositorySpy()
        var didClose = false
        let viewModel = AddCarViewModel(repository: repository) { didClose = true }

        viewModel.save()

        #expect(repository.addedCars.isEmpty)
        #expect(viewModel.errorMessage != nil)
        #expect(!didClose)
    }

    private func makeCar(brand: String) -> Car {
        Car(brand: brand, model: "Model", year: 2020, purchasePrice: 10_000, purchaseMileage: 1_000, purchaseDate: .now, powertrain: .petrol, energyCapacity: 50)
    }
}

@MainActor
private final class CarRepositorySpy: CarRepository {
    var addedCars: [Car] = []
    func fetchCars() throws -> [Car] { addedCars }
    func car(id: UUID) throws -> Car? { addedCars.first { $0.id == id } }
    func add(_ car: Car) throws { addedCars.append(car) }
}
