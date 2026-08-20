import Foundation
import Observation

@MainActor
@Observable
final class StatsViewModel {
    private let repository: any CarRepository
    private let selection: CarSelectionStore
    private let onRoute: (StatsRoute) -> Void

    var selectedPeriod: StatsPeriod = .month {
        didSet { load() }
    }
    
    private var selectedCar: Car?
    private(set) var stats: StatsPresentation = .empty
    private(set) var hasSelectedCar = false
    private(set) var errorMessage: String?

    init(repository: any CarRepository, selection: CarSelectionStore, onRoute: @escaping (StatsRoute) -> Void) {
        self.repository = repository
        self.selection = selection
        self.onRoute = onRoute
    }

    func load() {
        do {
            let cars = try repository.fetchCars()
            selection.reconcile(with: cars)
            selectedCar = cars.first { $0.id == selection.selectedCarID }
            hasSelectedCar = selectedCar != nil
            stats = PresentationMapper.stats(for: selectedCar, period: selectedPeriod)
            errorMessage = nil
        } catch { errorMessage = error.localizedDescription }
    }

    var emptyStateMessage: String {
        hasSelectedCar
            ? L10n.text("statistics.empty.description")
            : L10n.text("statistics.empty.noCar")
    }
    
    func didSelect(_ type: CarServiceType) {
        guard let selectedCar else {
            errorMessage = L10n.text("car.required")
            return
        }
        onRoute(type.statsRoute(for: selectedCar.id))
    }
}
