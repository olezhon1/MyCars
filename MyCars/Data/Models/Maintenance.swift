//
//  Maintenance.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 19.06.2026.
//

import Foundation
import SwiftData

@Model
class Maintenance {
    @Attribute(.unique) var id: UUID
    
    var title: String
    var price: Double
    var date: Date
    var mileage: Int
    var typeRaw: String = MaintenanceType.scheduled.rawValue
    
    var notes: String?
    
    var car: Car?
    
    var type: MaintenanceType {
        get { MaintenanceType(rawValue: typeRaw) ?? .scheduled }
        set { typeRaw = newValue.rawValue }
    }

    init(title: String, price: Double, mileage: Int, date: Date = Date(), notes: String? = nil, type: MaintenanceType = .scheduled) {
        self.id = UUID()
        self.title = title
        self.price = price
        self.mileage = mileage
        self.date = date
        self.notes = notes
        self.typeRaw = type.rawValue
    }
}

enum MaintenanceType: String, CaseIterable, Codable {
    case scheduled = "ТО"
    case repair = "Ремонт"
}
