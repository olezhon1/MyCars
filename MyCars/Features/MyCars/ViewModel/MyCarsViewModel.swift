import Foundation
import Observation

@MainActor
@Observable
final class MyCarsViewModel {
    private let repository: any CarRepository
    private let selection: CarSelectionStore
    private let onAddCar: () -> Void

    private(set) var cars: [CarPresentation] = []
    private(set) var selectedCarID: UUID?
    private(set) var errorMessage: String?

    init(repository: any CarRepository, selection: CarSelectionStore, onAddCar: @escaping () -> Void) {
        self.repository = repository
        self.selection = selection
        self.onAddCar = onAddCar
    }

    func load() {
        do {
            let models = try repository.fetchCars()
            selection.reconcile(with: models)
            selectedCarID = selection.selectedCarID
            cars = models.map(PresentationMapper.car)
            errorMessage = nil
        } catch { errorMessage = error.localizedDescription }
    }

    func onAddCarTapped() { onAddCar() }

    func onCarSelected(_ carID: UUID) {
        selection.select(carID)
        selectedCarID = carID
    }

    func dismissError() { errorMessage = nil }
}
