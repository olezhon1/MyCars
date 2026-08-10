import Foundation
import SwiftData

@Model
final class TireService {
    @Attribute(.unique) var id: UUID
    var title: String
    var price: Double
    var mileage: Int
    var date: Date
    var notes: String?
    var car: Car?

    init(title: String, price: Double, mileage: Int, date: Date = .now, notes: String? = nil) {
        id = UUID()
        self.title = title
        self.price = price
        self.mileage = mileage
        self.date = date
        self.notes = notes
    }
}
