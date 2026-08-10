import Foundation
import SwiftData

@MainActor
protocol CarRepository {
    func fetchCars() throws -> [Car]
    func car(id: UUID) throws -> Car?
    func add(_ car: Car) throws
}

@MainActor
protocol ExpenseRepository {
    func addRefill(to carID: UUID, mileage: Int, amount: Double, pricePerUnit: Double, isFullCharge: Bool, date: Date) throws
    func addWash(to carID: UUID, price: Double, mileage: Int?, date: Date) throws
    func addInsurance(to carID: UUID, type: InsuranceType, policyNumber: String, companyName: String, startDate: Date, endDate: Date, price: Double) throws
    func addMaintenance(to carID: UUID, title: String, price: Double, mileage: Int, date: Date, notes: String?) throws
    func addTuningModification(to carID: UUID, name: String, price: Double, date: Date, mileage: Int) throws
}

enum RepositoryError: LocalizedError {
    case carNotFound

    var errorDescription: String? {
        switch self {
        case .carNotFound: "Автомобіль не знайдено. Можливо, його було видалено."
        }
    }
}

@MainActor
final class SwiftDataRepository: CarRepository, ExpenseRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchCars() throws -> [Car] {
        var descriptor = FetchDescriptor<Car>()
        descriptor.sortBy = [SortDescriptor(\Car.purchaseDate, order: .reverse)]
        return try context.fetch(descriptor)
    }

    func car(id: UUID) throws -> Car? {
        let descriptor = FetchDescriptor<Car>(predicate: #Predicate { $0.id == id })
        return try context.fetch(descriptor).first
    }

    func add(_ car: Car) throws {
        context.insert(car)
        try context.save()
    }

    func addRefill(to carID: UUID, mileage: Int, amount: Double, pricePerUnit: Double, isFullCharge: Bool, date: Date) throws {
        let car = try requiredCar(id: carID)
        context.insert(EnergyRefill(car: car, mileage: mileage, amount: amount, pricePerUnit: pricePerUnit, isFullCharge: isFullCharge, date: date))
        try context.save()
    }

    func addWash(to carID: UUID, price: Double, mileage: Int?, date: Date) throws {
        let car = try requiredCar(id: carID)
        let wash = CarWash(price: price, mileage: mileage, date: date)
        wash.car = car
        context.insert(wash)
        try context.save()
    }

    func addInsurance(to carID: UUID, type: InsuranceType, policyNumber: String, companyName: String, startDate: Date, endDate: Date, price: Double) throws {
        let car = try requiredCar(id: carID)
        let insurance = Insurance(type: type, policyNumber: policyNumber, companyName: companyName, startDate: startDate, endDate: endDate, price: price)
        insurance.car = car
        context.insert(insurance)
        try context.save()
    }

    func addMaintenance(to carID: UUID, title: String, price: Double, mileage: Int, date: Date, notes: String?) throws {
        let car = try requiredCar(id: carID)
        let maintenance = Maintenance(title: title, price: price, mileage: mileage, date: date, notes: notes)
        maintenance.car = car
        context.insert(maintenance)
        try context.save()
    }
    
    func addTuningModification(to carID: UUID, name: String, price: Double, date: Date, mileage: Int) throws {
        let car = try requiredCar(id: carID)
        let tuning = TuningModification(name: name, price: price, date: date, mileage: mileage)
        tuning.car = car
        context.insert(tuning)
        try context.save()
    }

    private func requiredCar(id: UUID) throws -> Car {
        guard let car = try car(id: id) else { throw RepositoryError.carNotFound }
        return car
    }
}
