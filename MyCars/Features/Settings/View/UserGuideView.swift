import SwiftUI

struct UserGuideView: View {
    private let sections: [GuideSection] = [
        GuideSection(icon: "car.fill", color: .blue, titleKey: "guide.car.title", bodyKey: "guide.car.body"),
        GuideSection(icon: "plus.circle.fill", color: .green, titleKey: "guide.expenses.title", bodyKey: "guide.expenses.body"),
        GuideSection(icon: "chart.xyaxis.line", color: .purple, titleKey: "guide.statistics.title", bodyKey: "guide.statistics.body"),
        GuideSection(icon: "wrench.and.screwdriver.fill", color: .orange, titleKey: "guide.maintenance.title", bodyKey: "guide.maintenance.body"),
        GuideSection(icon: "shield.checkered", color: .indigo, titleKey: "guide.insurance.title", bodyKey: "guide.insurance.body"),
        GuideSection(icon: "bell.badge.fill", color: .pink, titleKey: "guide.notifications.title", bodyKey: "guide.notifications.body")
    ]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                    HStack(alignment: .top, spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(section.color.opacity(0.13))
                                .frame(width: 46, height: 46)
                            Image(systemName: section.icon)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(section.color)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text(L10n.text(section.titleKey))
                                .font(.headline)
                            Text(L10n.text(section.bodyKey))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(16)
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.primary.opacity(0.07), lineWidth: 1)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(accessibilityLabel(for: section, index: index))
                }
            }
            .padding(20)
        }
        .background(Color("background"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(L10n.text("settings.guide.title"))
    }

    private func accessibilityLabel(for section: GuideSection, index: Int) -> String {
        let title = L10n.text(section.titleKey)
        let body = L10n.text(section.bodyKey)
        return "\(index + 1). \(title). \(body)"
    }
}

private struct GuideSection {
    let icon: String
    let color: Color
    let titleKey: String
    let bodyKey: String
}
