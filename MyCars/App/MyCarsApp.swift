import SwiftUI
import SwiftData

@main
@MainActor
struct MyCarsApp: App {
    @Environment(\.scenePhase) private var scenePhase
    private let modelContainer: ModelContainer
    private let container: AppContainer
    @State private var router: AppRouter

    init() {
        let schema = Schema([Car.self, Insurance.self, TuningModification.self, CarWash.self, Maintenance.self, EnergyRefill.self, TireService.self, OtherExpense.self])
        do {
            let modelContainer = try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema)])
            self.modelContainer = modelContainer
            container = AppContainer(modelContext: modelContainer.mainContext)
            _router = State(initialValue: AppRouter())
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }

        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(named: "primary")
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(named: "primary")?.withAlphaComponent(0.2)
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor(named: "primary") ?? .black,
            .font: UIFont.systemFont(ofSize: 24, weight: .black)
        ]
    }

    var body: some Scene {
        WindowGroup {
            MainTabView(router: router, container: container)
        }
        .modelContainer(modelContainer)
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { try? await container.reminderService.synchronize() }
        }
    }
}
