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
        let schema = Schema([Car.self, Insurance.self, TuningModification.self, CarWash.self, Maintenance.self, EnergyRefill.self, TireService.self, OtherExpense.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let repository = SwiftDataRepository(context: container.mainContext)
        let car = makeCar(brand: "Dacia")
        let carID = try repository.add(data(from: car))

        try repository.addWash(to: carID, price: 300, mileage: 10_000, date: .now)

        let savedCar = try #require(try repository.car(id: carID))
        #expect(savedCar.washes.count == 1)
        #expect(savedCar.washes.first?.car?.id == carID)
        #expect(try repository.currentMileage(for: carID) == 10_000)
    }

    @Test func repositoryStoresNewExpenseTypes() throws {
        let schema = Schema([Car.self, Insurance.self, TuningModification.self, CarWash.self, Maintenance.self, EnergyRefill.self, TireService.self, OtherExpense.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let repository = SwiftDataRepository(context: container.mainContext)
        let car = makeCar(brand: "Dacia")
        let carID = try repository.add(data(from: car))

        try repository.addRepair(to: carID, title: "Гальма", price: 2_000, mileage: 12_000, date: .now, notes: nil)
        try repository.addTireService(to: carID, title: "Балансування", price: 500, mileage: 12_100, date: .now, notes: nil)
        try repository.addOtherExpense(to: carID, title: "Паркування", price: 100, mileage: nil, date: .now, notes: nil)

        let savedCar = try #require(try repository.car(id: carID))
        #expect(savedCar.maintenanceHistory.first?.type == .repair)
        #expect(savedCar.tireServices.count == 1)
        #expect(savedCar.otherExpenses.first?.mileage == nil)
    }

    @Test func addCarViewModelDoesNotCloseOnInvalidInput() {
        let repository = CarRepositorySpy()
        var didClose = false
        let viewModel = AddCarViewModel(repository: repository) { _ in didClose = true }

        viewModel.save()

        #expect(repository.addedCars.isEmpty)
        #expect(viewModel.errorMessage != nil)
        #expect(!didClose)
    }

    @Test func maintenanceIntervalIsEstimatedFromServiceMileages() {
        let car = makeCar(brand: "Dacia")
        car.maintenanceHistory = [
            Maintenance(title: "ТО 1", price: 1_000, mileage: 10_000),
            Maintenance(title: "Ремонт", price: 2_000, mileage: 20_000, type: .repair),
            Maintenance(title: "ТО 2", price: 1_500, mileage: 32_000)
        ]

        #expect(car.estimatedMaintenanceInterval == 22_000)
        #expect(car.kilometersUntilMaintenance == 22_000)
    }

    @Test func maintenanceIntervalRequiresTwoRecords() {
        let car = makeCar(brand: "Dacia")
        car.maintenanceHistory = [
            Maintenance(title: "ТО", price: 1_000, mileage: 10_000)
        ]

        #expect(car.estimatedMaintenanceInterval == nil)
        #expect(car.kilometersUntilMaintenance == nil)
    }

    private func makeCar(brand: String) -> Car {
        Car(brand: brand, model: "Model", year: 2020, purchasePrice: 10_000, purchaseMileage: 1_000, purchaseDate: .now, energyCapacity: 50)
    }

    private func data(from car: Car) -> CarData {
        CarData(
            brand: car.brand,
            model: car.model,
            year: car.year,
            purchasePrice: car.purchasePrice,
            purchaseMileage: car.purchaseMileage,
            purchaseDate: car.purchaseDate,
            energyCapacity: car.energyCapacity,
            imageData: car.imageData
        )
    }
}

@MainActor
private final class CarRepositorySpy: CarRepository {
    var addedCars: [Car] = []
    func fetchCars() throws -> [Car] { addedCars }
    func car(id: UUID) throws -> Car? { addedCars.first { $0.id == id } }
    func add(_ data: CarData) throws -> UUID {
        let car = Car(data: data)
        addedCars.append(car)
        return car.id
    }
    func update(carID: UUID, with data: CarData) throws {
        addedCars.first { $0.id == carID }?.update(with: data)
    }
    func delete(carID: UUID) throws { addedCars.removeAll { $0.id == carID } }
}
