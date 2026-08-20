#if DEBUG
import Foundation

@MainActor
final class DebugCarSeeder {
    private static let brand = "DEMO"

    private let repository: any CarRepository & ExpenseRepository
    private let calendar: Calendar
    private let now: Date

    init(
        repository: any CarRepository & ExpenseRepository,
        calendar: Calendar = .current,
        now: Date = .now
    ) {
        self.repository = repository
        self.calendar = calendar
        self.now = now
    }

    /// Creates only missing scenarios and returns the rich-history car to make it active.
    func seed() throws -> UUID? {
        let existingCars = try repository.fetchCars().filter { $0.brand == Self.brand }
        let existingIDs = existingCars.reduce(into: [String: UUID]()) { result, car in
            result[car.model] = result[car.model] ?? car.id
        }

        try seedFuelOnly(existingIDs)
        try seedWashOnly(existingIDs)
        try seedExpiredInsuranceOnly(existingIDs)
        try seedMaintenanceOnly(existingIDs)
        try seedTuningOnly(existingIDs)
        try seedRepairOnly(existingIDs)
        try seedTireServiceOnly(existingIDs)
        try seedOtherExpensesOnly(existingIDs)
        let fullHistoryID = try seedFullHistory(existingIDs)
        try seedEdgeCases(existingIDs)

        return fullHistoryID
    }

    private func seedFuelOnly(_ existing: [String: UUID]) throws {
        let (id, isNew) = try ensureCar(
            model: "01 · Лише заправки",
            year: 2021,
            price: 720_000,
            mileage: 10_000,
            capacity: 50,
            purchasedMonthsAgo: 24,
            existing: existing
        )
        guard isNew else { return }

        try addRefills(to: id, values: [
            (-18, 12_000, 42.5, 48.90),
            (-9, 17_000, 45.0, 51.40),
            (-3, 22_000, 39.8, 54.70),
            (-1, 23_200, 44.2, 55.20)
        ])
        try repository.addRefill(to: id, mileage: 24_050, amount: 36.7, pricePerUnit: 56.10, date: day(-8))
    }

    private func seedWashOnly(_ existing: [String: UUID]) throws {
        let (id, isNew) = try ensureCar(
            model: "02 · Лише мийки",
            year: 2019,
            price: 510_000,
            mileage: 48_000,
            capacity: 45,
            purchasedMonthsAgo: 20,
            existing: existing
        )
        guard isNew else { return }

        try repository.addWash(to: id, price: 280, mileage: 49_300, date: month(-14))
        try repository.addWash(to: id, price: 450, mileage: nil, date: month(-5))
        try repository.addWash(to: id, price: 650, mileage: 56_100, date: day(-10))
    }

    private func seedExpiredInsuranceOnly(_ existing: [String: UUID]) throws {
        let (id, isNew) = try ensureCar(
            model: "03 · Прострочена страховка",
            year: 2017,
            price: 380_000,
            mileage: 92_000,
            capacity: 55,
            purchasedMonthsAgo: 30,
            existing: existing
        )
        guard isNew else { return }

        try repository.addInsurance(
            to: id,
            type: .osago,
            policyNumber: "DEMO-OSAGO-EXPIRED",
            companyName: "Demo Insurance",
            startDate: month(-18),
            endDate: month(-6),
            price: 2_950
        )
    }

    private func seedMaintenanceOnly(_ existing: [String: UUID]) throws {
        let (id, isNew) = try ensureCar(
            model: "04 · Лише планове ТО",
            year: 2020,
            price: 640_000,
            mileage: 30_000,
            capacity: 52,
            purchasedMonthsAgo: 22,
            existing: existing
        )
        guard isNew else { return }

        try repository.addMaintenance(to: id, title: "ТО 40 000", price: 6_800, mileage: 40_000, date: month(-15), notes: "Мастило та фільтри")
        try repository.addMaintenance(to: id, title: "ТО 50 000", price: 8_200, mileage: 50_000, date: month(-7), notes: nil)
        try repository.addMaintenance(to: id, title: "ТО 60 000", price: 11_400, mileage: 60_000, date: day(-18), notes: "Мастило, фільтри, свічки")
    }

    private func seedTuningOnly(_ existing: [String: UUID]) throws {
        let (id, isNew) = try ensureCar(
            model: "05 · Лише тюнінг",
            year: 2022,
            price: 980_000,
            mileage: 14_000,
            capacity: 60,
            purchasedMonthsAgo: 16,
            existing: existing
        )
        guard isNew else { return }

        try repository.addTuningModification(to: id, name: "Захист двигуна", price: 7_500, date: month(-13), mileage: 15_200)
        try repository.addTuningModification(to: id, name: "Тонування", price: 6_000, date: month(-4), mileage: 20_800)
        try repository.addTuningModification(to: id, name: "Мультимедіа", price: 22_000, date: day(-12), mileage: 25_100)
    }

    private func seedRepairOnly(_ existing: [String: UUID]) throws {
        let (id, isNew) = try ensureCar(
            model: "06 · Лише ремонти",
            year: 2015,
            price: 310_000,
            mileage: 135_000,
            capacity: 58,
            purchasedMonthsAgo: 28,
            existing: existing
        )
        guard isNew else { return }

        try repository.addRepair(to: id, title: "Ремонт генератора", price: 9_500, mileage: 141_000, date: month(-17), notes: nil)
        try repository.addRepair(to: id, title: "Передня підвіска", price: 24_800, mileage: 149_500, date: month(-8), notes: "Важелі та сайлентблоки")
        try repository.addRepair(to: id, title: "Гальмівна система", price: 14_200, mileage: 154_300, date: day(-20), notes: "Диски та колодки")
    }

    private func seedTireServiceOnly(_ existing: [String: UUID]) throws {
        let (id, isNew) = try ensureCar(
            model: "07 · Лише шиномонтаж",
            year: 2023,
            price: 1_150_000,
            mileage: 5_000,
            capacity: 62,
            purchasedMonthsAgo: 14,
            existing: existing
        )
        guard isNew else { return }

        try repository.addTireService(to: id, title: "Літній комплект", price: 1_600, mileage: 8_000, date: month(-12), notes: nil)
        try repository.addTireService(to: id, title: "Зимовий комплект", price: 2_100, mileage: 18_500, date: month(-5), notes: "Зберігання включено")
        try repository.addTireService(to: id, title: "Ремонт проколу", price: 550, mileage: 22_300, date: day(-6), notes: nil)
    }

    private func seedOtherExpensesOnly(_ existing: [String: UUID]) throws {
        let (id, isNew) = try ensureCar(
            model: "08 · Лише інші витрати",
            year: 2018,
            price: 460_000,
            mileage: 70_000,
            capacity: 48,
            purchasedMonthsAgo: 25,
            existing: existing
        )
        guard isNew else { return }

        try repository.addOtherExpense(to: id, title: "Платна дорога", price: 420, mileage: 72_100, date: month(-15), notes: nil)
        try repository.addOtherExpense(to: id, title: "Паркінг", price: 1_800, mileage: nil, date: month(-4), notes: "Місячний абонемент")
        try repository.addOtherExpense(to: id, title: "Евакуатор", price: 3_500, mileage: 78_400, date: day(-4), notes: nil)
    }

    private func seedFullHistory(_ existing: [String: UUID]) throws -> UUID {
        let (id, isNew) = try ensureCar(
            model: "09 · Повна історія",
            year: 2022,
            price: 1_240_000,
            mileage: 20_000,
            capacity: 58,
            purchasedMonthsAgo: 26,
            existing: existing
        )
        guard isNew else { return id }

        try addRefills(to: id, values: [
            (-18, 24_000, 45.0, 47.80),
            (-9, 35_000, 41.5, 51.20),
            (-3, 47_000, 46.2, 54.90),
            (-1, 52_000, 43.8, 55.60)
        ])
        try repository.addRefill(to: id, mileage: 53_100, amount: 38.4, pricePerUnit: 56.20, date: day(-7))

        try repository.addWash(to: id, price: 350, mileage: 25_000, date: month(-16))
        try repository.addWash(to: id, price: 650, mileage: nil, date: month(-4))
        try repository.addWash(to: id, price: 900, mileage: 52_800, date: day(-9))

        try repository.addInsurance(to: id, type: .greenCard, policyNumber: "DEMO-GREEN-OLD", companyName: "Demo Insurance", startDate: month(-20), endDate: month(-19), price: 1_700)
        try repository.addInsurance(to: id, type: .kasko, policyNumber: "DEMO-KASKO-ACTIVE", companyName: "Safe Drive", startDate: month(-2), endDate: month(10), price: 34_500)

        try repository.addMaintenance(to: id, title: "ТО 30 000", price: 7_200, mileage: 30_000, date: month(-14), notes: nil)
        try repository.addMaintenance(to: id, title: "ТО 40 000", price: 9_600, mileage: 40_000, date: month(-7), notes: "Регламентні роботи")
        try repository.addMaintenance(to: id, title: "ТО 50 000", price: 12_400, mileage: 50_000, date: day(-24), notes: "Мастило, фільтри, свічки")

        try repository.addRepair(to: id, title: "Заміна акумулятора", price: 7_800, mileage: 38_200, date: month(-8), notes: nil)
        try repository.addRepair(to: id, title: "Ремонт кондиціонера", price: 11_300, mileage: 51_500, date: day(-16), notes: "Заміна компресора")

        try repository.addTuningModification(to: id, name: "Камера заднього огляду", price: 8_900, date: month(-11), mileage: 32_000)
        try repository.addTuningModification(to: id, name: "Шумоізоляція", price: 26_000, date: month(-3), mileage: 46_500)

        try repository.addTireService(to: id, title: "Сезонна заміна", price: 1_800, mileage: 36_000, date: month(-9), notes: nil)
        try repository.addTireService(to: id, title: "Балансування", price: 1_200, mileage: 52_300, date: day(-13), notes: nil)

        try repository.addOtherExpense(to: id, title: "Паркінг", price: 2_400, mileage: nil, date: month(-13), notes: "Абонемент")
        try repository.addOtherExpense(to: id, title: "Платна дорога", price: 680, mileage: 49_700, date: month(-2), notes: nil)
        try repository.addOtherExpense(to: id, title: "Хімчистка салону", price: 4_500, mileage: nil, date: day(-5), notes: nil)

        return id
    }

    private func seedEdgeCases(_ existing: [String: UUID]) throws {
        let (id, isNew) = try ensureCar(
            model: "10 · Граничні стани",
            year: 2024,
            price: 2_350_000,
            mileage: 0,
            capacity: 72.5,
            purchasedMonthsAgo: 13,
            existing: existing
        )
        guard isNew else { return }

        try addRefills(to: id, values: [
            (-13, 800, 12.3, 49.99),
            (-7, 8_500, 70.1, 52.75),
            (-2, 16_400, 8.75, 55.05)
        ])
        try repository.addRefill(to: id, mileage: 18_200, amount: 71.9, pricePerUnit: 56.49, date: day(-2))

        try repository.addWash(to: id, price: 0, mileage: nil, date: day(-1))
        try repository.addInsurance(to: id, type: .osago, policyNumber: "DEMO-OSAGO-OLD", companyName: "Safe Drive", startDate: month(-14), endDate: month(-2), price: 3_200)
        try repository.addInsurance(to: id, type: .greenCard, policyNumber: "DEMO-GREEN-SOON", companyName: "Travel Cover", startDate: month(-2), endDate: day(14), price: 4_750)
        try repository.addMaintenance(to: id, title: "Перше ТО", price: 0, mileage: 1_500, date: month(-11), notes: "Гарантійне")
        try repository.addMaintenance(to: id, title: "ТО 15 000", price: 15_900, mileage: 15_000, date: month(-3), notes: nil)
        try repository.addRepair(to: id, title: "Гарантійний ремонт", price: 0, mileage: 9_200, date: month(-6), notes: "Сплачено виробником")
        try repository.addTuningModification(to: id, name: "Захисна плівка", price: 58_000, date: month(-10), mileage: 2_000)
        try repository.addTireService(to: id, title: "Комплект зимових шин", price: 64_000, mileage: 7_500, date: month(-7), notes: "Шини та встановлення")
        try repository.addOtherExpense(to: id, title: "Реєстрація", price: 8_600, mileage: nil, date: month(-13), notes: nil)
        try repository.addOtherExpense(to: id, title: "Паркінг", price: 150, mileage: nil, date: day(-1), notes: nil)
    }

    private func ensureCar(
        model: String,
        year: Int,
        price: Double,
        mileage: Int,
        capacity: Double,
        purchasedMonthsAgo: Int,
        existing: [String: UUID]
    ) throws -> (id: UUID, isNew: Bool) {
        if let id = existing[model] {
            return (id, false)
        }

        let id = try repository.add(CarData(
            brand: Self.brand,
            model: model,
            year: year,
            purchasePrice: price,
            purchaseMileage: mileage,
            purchaseDate: month(-purchasedMonthsAgo),
            energyCapacity: capacity,
            imageData: nil
        ))
        return (id, true)
    }

    private func addRefills(
        to carID: UUID,
        values: [(monthOffset: Int, mileage: Int, amount: Double, pricePerUnit: Double)]
    ) throws {
        for value in values {
            try repository.addRefill(
                to: carID,
                mileage: value.mileage,
                amount: value.amount,
                pricePerUnit: value.pricePerUnit,
                date: month(value.monthOffset)
            )
        }
    }

    private func month(_ offset: Int) -> Date {
        calendar.date(byAdding: .month, value: offset, to: now) ?? now
    }

    private func day(_ offset: Int) -> Date {
        calendar.date(byAdding: .day, value: offset, to: now) ?? now
    }
}
#endif
