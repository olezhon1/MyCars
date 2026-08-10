import Foundation
import Observation

@MainActor
@Observable
final class MyCarsViewModel {
    private let repository: any CarRepository
    private let selection: CarSelectionStore
    private let onAddCar: () -> Void

    private let selectedPeriod: StatsPeriod = .allTime
    private var models: [Car] = []

    var selectedCarID: UUID? {
        selection.selectedCarID
    }

    private(set) var cars: [CarPresentation] = []
    private(set) var stats: StatsPresentation = .empty
    private(set) var errorMessage: String?

    init(repository: any CarRepository, selection: CarSelectionStore, onAddCar: @escaping () -> Void) {
        self.repository = repository
        self.selection = selection
        self.onAddCar = onAddCar
    }

    func load() {
        do {
            models = try repository.fetchCars()
            selection.reconcile(with: models)
            cars = models.map(PresentationMapper.car)
            updateStats()
            errorMessage = nil
        } catch { errorMessage = error.localizedDescription }
    }

    func onAddCarTapped() { onAddCar() }

    func onCarSelected(_ carID: UUID) {
        selection.select(carID)
        updateStats()
    }

    func dismissError() { errorMessage = nil }

    private func updateStats() {
        let selected = models.first { $0.id == selection.selectedCarID }
        stats = PresentationMapper.stats(for: selected, period: selectedPeriod)
    }
}
