//
//  TuningModification.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 19.06.2026.
//

import Foundation
import SwiftData

@Model
class TuningModification {
    @Attribute(.unique) var id: UUID
    
    var name: String
    var price: Double
    var date: Date
    var mileage: Int?
    
    var car: Car?
    
    init(name: String, price: Double, date: Date = Date(), mileage: Int? = nil) {
        self.id = UUID()
        self.name = name
        self.price = price
        self.date = date
        self.mileage = mileage
    }
}
