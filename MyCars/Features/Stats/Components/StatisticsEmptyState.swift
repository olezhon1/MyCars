import SwiftUI

struct StatisticsEmptyState: View {
    var serviceTitle: String?
    var message = "Додайте першу витрату для активного автомобіля — аналітика з’явиться тут автоматично."

    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: "chart.bar.xaxis",
            description: Text(message)
        )
    }

    private var title: String {
        serviceTitle.map { "Ще немає даних: \($0)" } ?? "Ще немає даних для статистики"
    }
}
