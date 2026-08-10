import Foundation
import Observation

@MainActor
@Observable
final class StatsViewModel {
    private let repository: any CarRepository
    private let selection: CarSelectionStore

    var selectedPeriod: StatsPeriod = .month {
        didSet { load() }
    }
    private(set) var stats: StatsPresentation = .empty
    private(set) var errorMessage: String?

    init(repository: any CarRepository, selection: CarSelectionStore) {
        self.repository = repository
        self.selection = selection
    }

    func load() {
        do {
            let cars = try repository.fetchCars()
            selection.reconcile(with: cars)
            let selected = cars.first { $0.id == selection.selectedCarID }
            stats = PresentationMapper.stats(for: selected, period: selectedPeriod)
            errorMessage = nil
        } catch { errorMessage = error.localizedDescription }
    }
}
