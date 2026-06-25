//
//  AddCarViewModel.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 24.06.2026.
//

import Foundation
import Observation
import SwiftData
import UIKit

@Observable
class AddCarViewModel {
    private let router: AppRouter
    private var context: ModelContext?

    var selectedImageData: Data? = nil
    var brand: String = ""
    var model: String = ""
    var year: String = ""
    var purchasePrice: String = ""
    var purchaseMileage: String = ""
    var purchaseDate: Date = .now
    var powertrain: PowertrainType = .petrol
    var energyCapacity: String = ""

    init(router: AppRouter) {
        self.router = router
    }
    

    // MARK: - Actions

    func setContext(_ context: ModelContext) {
        self.context = context
    }
    
    func save() {
        guard
            let year = Int(year),
            let price = Double(purchasePrice),
            let mileage = Int(purchaseMileage),
            let capacity = Double(energyCapacity),
            !brand.isEmpty,
            !model.isEmpty
        else {
            return
        }

        let car = Car(
            brand: brand,
            model: model,
            year: year,
            purchasePrice: price,
            purchaseMileage: mileage,
            purchaseDate: purchaseDate,
            powertrain: powertrain,
            energyCapacity: capacity,
            imageData: selectedImageData
        )

        context?.insert(car)
        router.pop()
    }
}
