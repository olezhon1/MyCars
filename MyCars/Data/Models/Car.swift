//
//  Car.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 19.06.2026.
//

import Foundation
import SwiftData

@Model
class Car {
    @Attribute(.unique) var id: UUID
    var brand: String
    var model: String
    var year: Int
    var purchasePrice: Double
    var purchaseMileage: Int
    var purchaseDate: Date
    var powertrainRaw: String
    var energyCapacity: Double
    
    @Attribute(.externalStorage) var imageData: Data?
    
    var currentMileage: Int {
        let fuelMileages = fuelHistory.map { $0.mileage }
        let repairMileages = maintenanceHistory.map { $0.mileage }
        let washMileages = washes.compactMap { $0.mileage }
        let tuningMileages = tuningModifications.compactMap { $0.mileage }
        
        let allMileages = fuelMileages + repairMileages + washMileages + tuningMileages
        
        return allMileages.max() ?? purchaseMileage
    }
    
    var totalDrivenKilometers: Int {
        currentMileage - purchaseMileage
    }
    
    @Relationship(deleteRule: .cascade, inverse: \Insurance.car)
    var insurances: [Insurance] = []
    
    @Relationship(deleteRule: .cascade, inverse: \TuningModification.car)
    var tuningModifications: [TuningModification] = []
    
    @Relationship(deleteRule: .cascade, inverse: \CarWash.car)
    var washes: [CarWash] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Maintenance.car)
    var maintenanceHistory: [Maintenance] = []
    
    @Relationship(deleteRule: .cascade, inverse: \EnergyRefill.car)
    var fuelHistory: [EnergyRefill] = []
    
    var activeInsurance: Insurance? {
        insurances.first(where: { $0.isActive })
    }
    
    init(brand: String, model: String, year: Int, purchasePrice: Double, purchaseMileage: Int, purchaseDate: Date, powertrain: PowertrainType, energyCapacity: Double, imageData: Data? = nil) {
        self.id = UUID()
        self.brand = brand
        self.model = model
        self.year = year
        self.purchasePrice = purchasePrice
        self.purchaseMileage = purchaseMileage
        self.purchaseDate = purchaseDate
        self.powertrainRaw = powertrain.rawValue
        self.energyCapacity = energyCapacity
        self.imageData = imageData
    }
}

enum PowertrainType: String, CaseIterable, Codable {
    case petrol = "Бензин"
    case diesel = "Дизель"
    case electric = "Електро"
    case hybrid = "Гібрид"
    case lpg = "Газ (Пропан-Бутан)"
    case cng = "Газ (Метан)"
}
