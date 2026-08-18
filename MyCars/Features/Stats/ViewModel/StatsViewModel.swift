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
            stats = PresentationMapper.stats(for: selectedCar, period: selectedPeriod)
            errorMessage = nil
        } catch { errorMessage = error.localizedDescription }
    }
    
    func didSelect(_ type: CarServiceType) {
        guard let selectedCar else {
            errorMessage = "Спочатку додайте автомобіль."
            return
        }
        onRoute(type.route(for: selectedCar))
    }
}
