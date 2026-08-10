import Foundation
import SwiftData

@MainActor
final class AppContainer {
    let carRepository: any CarRepository
    let expenseRepository: any ExpenseRepository
    let carSelection: CarSelectionStore

    // REVIEW: Composition root. Concrete SwiftData dependencies are created only here.
    init(modelContext: ModelContext, defaults: UserDefaults = .standard) {
        let repository = SwiftDataRepository(context: modelContext)
        carRepository = repository
        expenseRepository = repository
        carSelection = CarSelectionStore(defaults: defaults)
    }
}
