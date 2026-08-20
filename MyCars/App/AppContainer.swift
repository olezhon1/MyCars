import Foundation
import SwiftData

@MainActor
final class AppContainer {
    let carRepository: any CarRepository
    let expenseRepository: any ExpenseRepository
    let carSelection: CarSelectionStore
    let settings: AppSettings
    let reminderService: ReminderService
#if DEBUG
    let debugCarSeeder: DebugCarSeeder
#endif

    // REVIEW: Composition root. Concrete SwiftData dependencies are created only here.
    init(modelContext: ModelContext, defaults: UserDefaults = .standard) {
        let repository = SwiftDataRepository(context: modelContext)
        carRepository = repository
        expenseRepository = repository
        carSelection = CarSelectionStore(defaults: defaults)
        settings = AppSettings(defaults: defaults)
        reminderService = ReminderService(
            repository: repository,
            settings: settings,
            defaults: defaults
        )
#if DEBUG
        debugCarSeeder = DebugCarSeeder(repository: repository)
#endif
    }
}
