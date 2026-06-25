//
//  CarWash.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 19.06.2026.
//

import Foundation
import SwiftData

@Model
class CarWash {
    @Attribute(.unique) var id: UUID
    
    var price: Double
    var date: Date
    var mileage: Int?
    
    var car: Car?
    
    init(price: Double, date: Date = Date(), mileage: Int? = nil) {
        self.id = UUID()
        self.price = price
        self.date = date
        self.mileage = mileage
    }
}
