//
//  EnergyRefill.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 19.06.2026.
//

import Foundation
import SwiftData

@Model
class EnergyRefill {
    @Attribute(.unique) var id: UUID
    
    var date: Date
    var mileage: Int
    var amount: Double
    var pricePerUnit: Double
    var isFullCharge: Bool
    
    var totalPrice: Double {
        amount * pricePerUnit
    }
    
    var car: Car?
    
    init(mileage: Int, amount: Double, pricePerUnit: Double, isFullCharge: Bool, date: Date = Date()) {
        self.id = UUID()
        self.mileage = mileage
        self.amount = amount
        self.pricePerUnit = pricePerUnit
        self.isFullCharge = isFullCharge
        self.date = date
    }
}
