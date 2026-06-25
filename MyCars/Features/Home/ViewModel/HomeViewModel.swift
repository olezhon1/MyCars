//
//  HomeViewModel.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 06.06.2026.
//

import Foundation
import Observation

@Observable
final class HomeViewModel {
    private let router: AppRouter

    init(router: AppRouter) {
        self.router = router
    }

    // MARK: - Actions
    
    func didSelect(_ type: CarServiceType) {
        router.push(type.route)
    }
}
