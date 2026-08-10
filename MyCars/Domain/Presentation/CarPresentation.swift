import Foundation

struct CarPresentation: Identifiable, Equatable {
    let id: UUID
    let title: String
    let purchasePrice: String
    let purchaseMileage: String
    let currentMileage: String
    let totalExpenses: String
    let averageConsumption: String
    let imageData: Data?
    let insuranceEndDate: Date?
}

struct StatsPresentation: Equatable {
    let totalExpenses: String
    let costPerKilometer: String
    let valuesByService: [CarServiceType: String]

    static let empty = StatsPresentation(totalExpenses: "0 грн", costPerKilometer: "0 грн / км", valuesByService: [:])
}

enum PresentationMapper {
    static func car(_ car: Car) -> CarPresentation {
        let total = totalExpenses(for: car)
        return CarPresentation(
            id: car.id,
            title: "\(car.brand) \(car.model) — \(car.year)",
            purchasePrice: car.purchasePrice.formatted(.currency(code: "UAH")),
            purchaseMileage: "\(car.purchaseMileage.formatted()) км",
            currentMileage: "\(car.currentMileage.formatted()) км",
            totalExpenses: total.formatted(.currency(code: "UAH")),
            averageConsumption: averageConsumption(for: car).map { "\($0.formatted(.number.precision(.fractionLength(1)))) л" } ?? "—",
            imageData: car.imageData,
            insuranceEndDate: car.activeInsurance?.endDate
        )
    }

    static func stats(for car: Car?, period: StatsPeriod) -> StatsPresentation {
        guard let car else { return .empty }
        let startDate = period.startDate
        let fuel = car.fuelHistory.filter { $0.date >= startDate }.reduce(0) { $0 + $1.totalPrice }
        let maintenance = car.maintenanceHistory.filter { $0.date >= startDate }.reduce(0) { $0 + $1.price }
        let washes = car.washes.filter { $0.date >= startDate }.reduce(0) { $0 + $1.price }
        let insurance = car.insurances.filter { $0.startDate >= startDate }.reduce(0) { $0 + $1.price }
        let tuning = car.tuningModifications.filter { $0.date >= startDate }.reduce(0) { $0 + $1.price }
        let total = fuel + maintenance + washes + insurance + tuning
        let kilometers = max(car.totalDrivenKilometers, 0)
        let perKilometer = kilometers > 0 ? total / Double(kilometers) : 0
        return StatsPresentation(
            totalExpenses: total.formatted(.currency(code: "UAH")),
            costPerKilometer: "\(perKilometer.formatted(.currency(code: "UAH"))) / км",
            valuesByService: [
                .fuel: fuel.formatted(.currency(code: "UAH")),
                .maintenance: maintenance.formatted(.currency(code: "UAH")),
                .wash: washes.formatted(.currency(code: "UAH")),
                .insurance: insurance.formatted(.currency(code: "UAH")),
                .tuning: tuning.formatted(.currency(code: "UAH"))
            ]
        )
    }

    private static func totalExpenses(for car: Car) -> Double {
        car.fuelHistory.reduce(0) { $0 + $1.totalPrice }
        + car.maintenanceHistory.reduce(0) { $0 + $1.price }
        + car.washes.reduce(0) { $0 + $1.price }
        + car.insurances.reduce(0) { $0 + $1.price }
        + car.tuningModifications.reduce(0) { $0 + $1.price }
    }

    private static func averageConsumption(for car: Car) -> Double? {
        let refills = car.fuelHistory.sorted { $0.mileage < $1.mileage }
        guard let first = refills.first, let last = refills.last, last.mileage > first.mileage else { return nil }
        let amount = refills.dropFirst().reduce(0) { $0 + $1.amount }
        return amount / Double(last.mileage - first.mileage) * 100
    }
}
