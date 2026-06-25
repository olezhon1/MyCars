//
//  MyCarsViewModel.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 19.06.2026.
//

import Foundation
import Observation

@Observable
class MyCarsViewModel {
    private let router: AppRouter
    private(set) var cars: [Car] = []

    init(router: AppRouter) {
        self.router = router
    }

    // MARK: - Actions
    
    func setCars(_ cars: [Car]) {
        self.cars = cars
    }
    
    func onAddCarTapped() {
        router.push(CarsRoute.addCar)
    }
}
