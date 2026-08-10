//
//  Insurance.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 19.06.2026.
//

import Foundation
import SwiftData

@Model
class Insurance {
    @Attribute(.unique) var id: UUID
    var typeRaw: String
    var policyNumber: String
    var companyName: String
    var startDate: Date
    var endDate: Date
    var price: Double
    
    var car: Car?
    
    var isActive: Bool {
        let today = Date()
        return today >= startDate && today <= endDate
    }
    
    init(type: InsuranceType, policyNumber: String, companyName: String, startDate: Date, endDate: Date, price: Double) {
        self.id = UUID()
        self.typeRaw = type.rawValue
        self.policyNumber = policyNumber
        self.companyName = companyName
        self.startDate = startDate
        self.endDate = endDate
        self.price = price
    }
}

enum InsuranceType: String, CaseIterable {
    case none = "Не обрано"
    case osago = "Автоцивілка"
    case kasko = "КАСКО"
    case greenCard = "Зелена картка"
}
