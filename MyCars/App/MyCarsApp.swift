//
//  MyCarsApp.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 05.06.2026.
//

import SwiftUI
import SwiftData

@main
struct MyCarsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Car.self,
            Insurance.self,
            TuningModification.self,
            CarWash.self,
            Maintenance.self,
            EnergyRefill.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var router = AppRouter()
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(named: "primary")
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(named: "primary")?.withAlphaComponent(0.2)
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor(named: "primary") ?? .black,
            .font: UIFont.systemFont(ofSize: 24, weight: .black)
        ]
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(router)
        }
        .modelContainer(sharedModelContainer)
    }
}
