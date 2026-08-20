import Foundation

struct CarPresentation: Identifiable, Equatable {
    let id: UUID
    let title: String
    let purchasePrice: String
    let purchaseMileage: String
    let currentMileage: String
    let maintenanceStatus: String
    let totalExpenses: String
    let averageConsumption: String
    let imageData: Data?
    let insuranceEndDate: Date?
}

struct StatsPresentation: Equatable {
    let totalExpenses: String
    let costPerKilometer: String
    let valuesByService: [CarServiceType: String]
    let hasData: Bool

    static var empty: StatsPresentation {
        StatsPresentation(
            totalExpenses: L10n.currency(0),
            costPerKilometer: "\(L10n.currency(0)) / \(L10n.text("unit.kilometers"))",
            valuesByService: [:],
            hasData: false
        )
    }
}

struct ExpensePoint: Identifiable {
    let id = UUID()
    let month: Date
    let amount: Double

    static let empty = ExpensePoint(month: Date(), amount: 0)
}

struct ExpenseHistoryItem: Identifiable {
    let id: UUID
    let imageName: String?
    let amount: Double
    let mileage: Int?
    let date: Date
    let dateTitle: String
}

struct ExpenseMonthSection: Identifiable {
    let month: Date
    let items: [ExpenseHistoryItem]

    var id: Date { month }
}

enum PresentationMapper {
    static func car(_ car: Car) -> CarPresentation {
        let total = totalExpenses(for: car)
        return CarPresentation(
            id: car.id,
            title: "\(car.brand) \(car.model) — \(car.year)",
            purchasePrice: L10n.currency(car.purchasePrice),
            purchaseMileage: "\(L10n.integer(car.purchaseMileage)) \(L10n.text("unit.kilometers"))",
            currentMileage: "\(L10n.integer(car.currentMileage)) \(L10n.text("unit.kilometers"))",
            maintenanceStatus: maintenanceStatus(for: car),
            totalExpenses: L10n.currency(total),
            averageConsumption: averageConsumption(for: car).map {
                "\($0.formatted(.number.precision(.fractionLength(1)).locale(L10n.locale))) \(L10n.text("unit.litersPer100Kilometers"))"
            } ?? "—",
            imageData: car.imageData,
            insuranceEndDate: car.latestInsurance?.endDate
        )
    }

    static func stats(for car: Car?, period: StatsPeriod) -> StatsPresentation {
        guard let car else { return .empty }
        let startDate = period.startDate
        let fuel = car.fuelHistory.filter { $0.date >= startDate }.reduce(0) { $0 + $1.totalPrice }
        let maintenance = car.maintenanceHistory.filter { $0.date >= startDate && $0.type == .scheduled }.reduce(0) { $0 + $1.price }
        let repairs = car.maintenanceHistory.filter { $0.date >= startDate && $0.type == .repair }.reduce(0) { $0 + $1.price }
        let washes = car.washes.filter { $0.date >= startDate }.reduce(0) { $0 + $1.price }
        let insurance = car.insurances.filter { $0.startDate >= startDate }.reduce(0) { $0 + $1.price }
        let tuning = car.tuningModifications.filter { $0.date >= startDate }.reduce(0) { $0 + $1.price }
        let tireServices = car.tireServices.filter { $0.date >= startDate }.reduce(0) { $0 + $1.price }
        let otherExpenses = car.otherExpenses.filter { $0.date >= startDate }.reduce(0) { $0 + $1.price }
        let total = fuel + maintenance + repairs + washes + insurance + tuning + tireServices + otherExpenses
        let kilometers = max(car.totalDrivenKilometers, 0)
        let perKilometer = kilometers > 0 ? total / Double(kilometers) : 0
        return StatsPresentation(
            totalExpenses: L10n.currency(total),
            costPerKilometer: "\(L10n.currency(perKilometer)) / \(L10n.text("unit.kilometers"))",
            valuesByService: [
                .fuel: L10n.currency(fuel),
                .maintenance: L10n.currency(maintenance),
                .repair: L10n.currency(repairs),
                .wash: L10n.currency(washes),
                .insurance: L10n.currency(insurance),
                .tuning: L10n.currency(tuning),
                .tireService: L10n.currency(tireServices),
                .otherExpenses: L10n.currency(otherExpenses)
            ],
            hasData: total > 0
        )
    }
    
    static func expensesForService(for car: Car?, period: StatsPeriod, service: CarServiceType) -> [ExpensePoint] {
        guard let car else { return [] }
        let startDate = period.startDate

        switch service {
        case .fuel:
            return monthlyExpenses(
                from: car.fuelHistory,
                startDate: startDate,
                date: { $0.date },
                price: { $0.totalPrice }
            )
        case .maintenance:
            return monthlyExpenses(
                from: car.maintenanceHistory.filter { $0.type == .scheduled },
                startDate: startDate,
                date: { $0.date },
                price: { $0.price }
            )
        case .repair:
            return monthlyExpenses(
                from: car.maintenanceHistory.filter { $0.type == .repair },
                startDate: startDate,
                date: { $0.date },
                price: { $0.price }
            )
        case .wash:
            return monthlyExpenses(
                from: car.washes,
                startDate: startDate,
                date: { $0.date },
                price: { $0.price }
            )
        case .insurance:
            return monthlyExpenses(
                from: car.insurances,
                startDate: startDate,
                date: { $0.startDate },
                price: { $0.price }
            )
        case .tuning:
            return monthlyExpenses(
                from: car.tuningModifications,
                startDate: startDate,
                date: { $0.date },
                price: { $0.price }
            )
        case .tireService:
            return monthlyExpenses(
                from: car.tireServices,
                startDate: startDate,
                date: { $0.date },
                price: { $0.price }
            )
        case .otherExpenses:
            return monthlyExpenses(
                from: car.otherExpenses,
                startDate: startDate,
                date: { $0.date },
                price: { $0.price }
            )
        }
    }

    static func expenseHistory(
        for car: Car?,
        period: StatsPeriod,
        service: CarServiceType
    ) -> [ExpenseMonthSection] {
        guard let car else { return [] }
        let startDate = period.startDate
        let imageName = service.image
        let items: [ExpenseHistoryItem]

        switch service {
        case .fuel:
            items = car.fuelHistory.map {
                ExpenseHistoryItem(
                    id: $0.id,
                    imageName: imageName,
                    amount: $0.totalPrice,
                    mileage: $0.mileage,
                    date: $0.date,
                    dateTitle: L10n.text("refuel.field.date")
                )
            }
        case .maintenance:
            items = car.maintenanceHistory.filter { $0.type == .scheduled }.map {
                ExpenseHistoryItem(
                    id: $0.id,
                    imageName: imageName,
                    amount: $0.price,
                    mileage: $0.mileage,
                    date: $0.date,
                    dateTitle: L10n.text("history.date.maintenance")
                )
            }
        case .repair:
            items = car.maintenanceHistory.filter { $0.type == .repair }.map {
                ExpenseHistoryItem(
                    id: $0.id,
                    imageName: imageName,
                    amount: $0.price,
                    mileage: $0.mileage,
                    date: $0.date,
                    dateTitle: L10n.text("repair.field.date")
                )
            }
        case .wash:
            items = car.washes.map {
                ExpenseHistoryItem(
                    id: $0.id,
                    imageName: imageName,
                    amount: $0.price,
                    mileage: $0.mileage,
                    date: $0.date,
                    dateTitle: L10n.text("carWash.field.date")
                )
            }
        case .insurance:
            items = car.insurances.map {
                ExpenseHistoryItem(
                    id: $0.id,
                    imageName: imageName,
                    amount: $0.price,
                    mileage: nil,
                    date: $0.startDate,
                    dateTitle: L10n.text("history.date.insurance")
                )
            }
        case .tuning:
            items = car.tuningModifications.map {
                ExpenseHistoryItem(
                    id: $0.id,
                    imageName: imageName,
                    amount: $0.price,
                    mileage: $0.mileage,
                    date: $0.date,
                    dateTitle: L10n.text("history.date.tuning")
                )
            }
        case .tireService:
            items = car.tireServices.map {
                ExpenseHistoryItem(
                    id: $0.id,
                    imageName: imageName,
                    amount: $0.price,
                    mileage: $0.mileage,
                    date: $0.date,
                    dateTitle: L10n.text("tireService.field.date")
                )
            }
        case .otherExpenses:
            items = car.otherExpenses.map {
                ExpenseHistoryItem(
                    id: $0.id,
                    imageName: imageName,
                    amount: $0.price,
                    mileage: $0.mileage,
                    date: $0.date,
                    dateTitle: L10n.text("otherExpense.field.date")
                )
            }
        }

        let calendar = Calendar.current
        let filteredItems = items.filter { $0.date >= startDate }
        let groupedItems = Dictionary(grouping: filteredItems) {
            calendar.dateComponents([.year, .month], from: $0.date)
        }

        return groupedItems.compactMap { components, items in
            guard let month = calendar.date(from: components) else { return nil }
            return ExpenseMonthSection(
                month: month,
                items: items.sorted { $0.date > $1.date }
            )
        }
        .sorted { $0.month > $1.month }
    }

    private static func totalExpenses(for car: Car) -> Double {
        car.fuelHistory.reduce(0) { $0 + $1.totalPrice }
        + car.maintenanceHistory.reduce(0) { $0 + $1.price }
        + car.washes.reduce(0) { $0 + $1.price }
        + car.insurances.reduce(0) { $0 + $1.price }
        + car.tuningModifications.reduce(0) { $0 + $1.price }
        + car.tireServices.reduce(0) { $0 + $1.price }
        + car.otherExpenses.reduce(0) { $0 + $1.price }
    }

    private static func maintenanceStatus(for car: Car) -> String {
        guard let kilometers = car.kilometersUntilMaintenance else { return "—" }

        if kilometers > 0 {
            return "\(L10n.integer(kilometers)) \(L10n.text("unit.kilometers"))"
        }

        if kilometers == 0 {
            return L10n.text("common.now")
        }

        return L10n.text("maintenance.overdue", L10n.integer(abs(kilometers)))
    }

    private static func averageConsumption(for car: Car) -> Double? {
        let refills = car.fuelHistory.sorted { $0.mileage < $1.mileage }
        guard let first = refills.first, let last = refills.last, last.mileage > first.mileage else { return nil }
        let amount = refills.dropFirst().reduce(0) { $0 + $1.amount }
        return amount / Double(last.mileage - first.mileage) * 100
    }

    private static func monthlyExpenses<T>(
        from records: [T],
        startDate: Date,
        date: (T) -> Date,
        price: (T) -> Double
    ) -> [ExpensePoint] {
        let calendar = Calendar.current
        
        let filtered = records.filter { date($0) >= startDate }
        
        let grouped = Dictionary(grouping: filtered) { record in
            calendar.dateComponents([.year, .month], from: date(record))
        }
        
        return grouped.map { components, records in
            let sum = records.reduce(0) { $0 + price($1) }
            let monthDate = calendar.date(from: components) ?? Date()
            return ExpensePoint(month: monthDate, amount: sum)
        }
        .sorted { $0.month < $1.month }
    }
}
