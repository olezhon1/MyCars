import SwiftUI

struct StatisticsEmptyState: View {
    var serviceTitle: String?
    var message = L10n.text("statistics.empty.description")

    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: "chart.bar.xaxis",
            description: Text(message)
        )
    }

    private var title: String {
        serviceTitle.map { L10n.text("statistics.empty.service", $0) }
            ?? L10n.text("statistics.empty.title")
    }
}
