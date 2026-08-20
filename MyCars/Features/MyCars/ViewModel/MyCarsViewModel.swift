import Foundation
import Observation

@MainActor
@Observable
final class MyCarsViewModel {
    private let repository: any CarRepository
    private let selection: CarSelectionStore
    private let onAddCar: () -> Void
    private let onEditCar: (UUID) -> Void
    private let onCreateDebugCars: (() throws -> UUID?)?

    private let selectedPeriod: StatsPeriod = .allTime
    private var models: [Car] = []

    var selectedCarID: UUID? {
        selection.selectedCarID
    }

    private(set) var cars: [CarPresentation] = []
    private(set) var stats: StatsPresentation = .empty
    private(set) var errorMessage: String?
    private(set) var debugMessage: String?

    init(
        repository: any CarRepository,
        selection: CarSelectionStore,
        onAddCar: @escaping () -> Void,
        onEditCar: @escaping (UUID) -> Void,
        onCreateDebugCars: (() throws -> UUID?)? = nil
    ) {
        self.repository = repository
        self.selection = selection
        self.onAddCar = onAddCar
        self.onEditCar = onEditCar
        self.onCreateDebugCars = onCreateDebugCars
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

    func onEditCarTapped(_ carID: UUID) { onEditCar(carID) }

    func onCarSelected(_ carID: UUID) {
        selection.select(carID)
        updateStats()
    }

    func deleteCar(_ carID: UUID) {
        do {
            try repository.delete(carID: carID)
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func dismissError() { errorMessage = nil }

    func createDebugCars() {
        guard let onCreateDebugCars else { return }

        do {
            if let activeCarID = try onCreateDebugCars() {
                selection.select(activeCarID)
            }
            load()
            debugMessage = "10 тестових автомобілів готові. Повторне натискання відновить лише видалені сценарії."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func dismissDebugMessage() { debugMessage = nil }

    private func updateStats() {
        let selected = models.first { $0.id == selection.selectedCarID }
        stats = PresentationMapper.stats(for: selected, period: selectedPeriod)
    }
}
