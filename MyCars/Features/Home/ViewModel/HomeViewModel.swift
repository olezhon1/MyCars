import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    private let repository: any CarRepository
    private let selection: CarSelectionStore
    private let onRoute: (HomeRoute) -> Void

    private(set) var cars: [CarPresentation] = []
    private(set) var selectedCarID: UUID?
    private(set) var errorMessage: String?

    init(repository: any CarRepository, selection: CarSelectionStore, onRoute: @escaping (HomeRoute) -> Void) {
        self.repository = repository
        self.selection = selection
        self.onRoute = onRoute
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

    func selectCar(_ id: UUID) {
        selection.select(id)
        selectedCarID = id
    }

    func didSelect(_ type: CarServiceType) {
        guard let selectedCarID else {
            errorMessage = L10n.text("car.required")
            return
        }
        onRoute(type.route(for: selectedCarID))
    }
}
