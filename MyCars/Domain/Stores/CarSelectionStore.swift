import Foundation
import Observation

@MainActor
@Observable
final class CarSelectionStore {
    private(set) var selectedCarID: UUID?
    private let defaults: UserDefaults
    private let storageKey = "currentCarID"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        selectedCarID = defaults.string(forKey: storageKey).flatMap(UUID.init(uuidString:))
    }

    func select(_ carID: UUID) {
        selectedCarID = carID
        defaults.set(carID.uuidString, forKey: storageKey)
    }

    func reconcile(with cars: [Car]) {
        if let selectedCarID, cars.contains(where: { $0.id == selectedCarID }) { return }
        guard let firstID = cars.first?.id else {
            clear()
            return
        }
        select(firstID)
    }

    func clear() {
        selectedCarID = nil
        defaults.removeObject(forKey: storageKey)
    }
}
