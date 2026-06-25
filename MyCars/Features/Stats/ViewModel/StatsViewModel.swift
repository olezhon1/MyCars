//
//  StatsViewModel.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 24.06.2026.
//

import Foundation
import Observation

@Observable
class StatsViewModel {
    private let router: AppRouter
    var selectedPeriod: StatsPeriod = .month

    init(router: AppRouter) {
        self.router = router
    }

    // MARK: - Actions
    
    func onAddCarTapped() {
        router.push(CarsRoute.addCar)
    }
    
    func didSelect(_ type: CarServiceType) {
        router.push(type.route)
    }
}
