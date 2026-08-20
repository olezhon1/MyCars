import SwiftUI
import UIKit

struct SettingsView: View {
    @Bindable var settings: AppSettings
    let reminderService: ReminderService

    @Environment(\.openURL) private var openURL
    @State private var permissionState: ReminderPermissionState = .unknown
    @State private var errorMessage: String?
    @State private var isSynchronizing = false

    private let insuranceLeadOptions = [7, 14, 30]
    private let maintenanceThresholdOptions = [500, 1_000, 2_000]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 18) {
                remindersCard
                generalCard
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color("background"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(L10n.text("settings.title").uppercased())
        .task { await refreshAndSynchronize() }
        .alert(L10n.text("common.error"), isPresented: errorPresented) {
            Button("common.ok") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? L10n.text("common.unknownError"))
        }
    }

    private var remindersCard: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    SettingsIcon(symbol: "bell.badge.fill", colors: [.orange, .pink])

                    VStack(alignment: .leading, spacing: 3) {
                        Text(L10n.text("settings.reminders.title"))
                            .font(.headline)
                        Text(L10n.text("settings.reminders.subtitle"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                    permissionBadge
                }

                Divider()

                ReminderToggleRow(
                    symbol: "shield.checkered",
                    title: L10n.text("settings.reminders.insurance.title"),
                    subtitle: L10n.text("settings.reminders.insurance.subtitle"),
                    tint: .blue,
                    isOn: insuranceBinding
                )

                if settings.insuranceRemindersEnabled {
                    optionMenu(
                        title: L10n.text("settings.reminders.insurance.lead"),
                        value: L10n.text("settings.reminders.daysBefore", settings.insuranceLeadDays)
                    ) {
                        ForEach(insuranceLeadOptions, id: \.self) { days in
                            Button(L10n.text("settings.reminders.daysBefore", days)) {
                                settings.insuranceLeadDays = days
                                synchronizeReminders()
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Divider()

                ReminderToggleRow(
                    symbol: "wrench.and.screwdriver.fill",
                    title: L10n.text("settings.reminders.maintenance.title"),
                    subtitle: L10n.text("settings.reminders.maintenance.subtitle"),
                    tint: .orange,
                    isOn: maintenanceBinding
                )

                if settings.maintenanceRemindersEnabled {
                    optionMenu(
                        title: L10n.text("settings.reminders.maintenance.threshold"),
                        value: L10n.text("settings.reminders.kilometers", settings.maintenanceThreshold)
                    ) {
                        ForEach(maintenanceThresholdOptions, id: \.self) { kilometers in
                            Button(L10n.text("settings.reminders.kilometers", kilometers)) {
                                settings.maintenanceThreshold = kilometers
                                synchronizeReminders()
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                if permissionState == .denied {
                    permissionWarning
                }

                Text(L10n.text("settings.reminders.footnote"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .animation(.easeInOut(duration: 0.2), value: settings.insuranceRemindersEnabled)
            .animation(.easeInOut(duration: 0.2), value: settings.maintenanceRemindersEnabled)
        }
    }

    private var generalCard: some View {
        SettingsCard {
            VStack(spacing: 0) {
                Menu {
                    ForEach(AppLanguage.allCases) { language in
                        Button {
                            settings.language = language
                            synchronizeReminders()
                        } label: {
                            if settings.language == language {
                                Label(language.title, systemImage: "checkmark")
                            } else {
                                Text(language.title)
                            }
                        }
                    }
                } label: {
                    SettingsNavigationRow(
                        symbol: "globe",
                        title: L10n.text("settings.language.title"),
                        value: settings.language.title,
                        tint: .indigo,
                        showsChevron: true
                    )
                }
                .buttonStyle(.plain)

                Divider().padding(.leading, 52)

                NavigationLink {
                    UserGuideView()
                } label: {
                    SettingsNavigationRow(
                        symbol: "book.closed.fill",
                        title: L10n.text("settings.guide.title"),
                        value: nil,
                        tint: .green,
                        showsChevron: true
                    )
                }
                .buttonStyle(.plain)

                Divider().padding(.leading, 52)

                SettingsNavigationRow(
                    symbol: "app.badge.fill",
                    title: L10n.text("settings.version.title"),
                    value: appVersion,
                    tint: .purple,
                    showsChevron: false
                )
            }
        }
    }

    @ViewBuilder
    private var permissionBadge: some View {
        if isSynchronizing {
            ProgressView()
                .controlSize(.small)
        } else {
            Text(permissionBadgeTitle)
                .font(.caption2.weight(.bold))
                .foregroundStyle(permissionBadgeColor)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(permissionBadgeColor.opacity(0.12), in: Capsule())
        }
    }

    private var permissionWarning: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(L10n.text("settings.reminders.permissionDenied"), systemImage: "exclamationmark.triangle.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.orange)

            Button(L10n.text("settings.reminders.openSystemSettings")) {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                openURL(url)
            }
            .font(.caption.weight(.semibold))
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    private func optionMenu<MenuContent: View>(
        title: String,
        value: String,
        @ViewBuilder content: () -> MenuContent
    ) -> some View {
        Menu(content: content) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(value)
                    .font(.subheadline.weight(.semibold))
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.leading, 44)
        }
        .buttonStyle(.plain)
    }

    private var insuranceBinding: Binding<Bool> {
        Binding(
            get: { settings.insuranceRemindersEnabled },
            set: { updateReminder(.insurance, enabled: $0) }
        )
    }

    private var maintenanceBinding: Binding<Bool> {
        Binding(
            get: { settings.maintenanceRemindersEnabled },
            set: { updateReminder(.maintenance, enabled: $0) }
        )
    }

    private var errorPresented: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )
    }

    private var permissionBadgeTitle: String {
        switch permissionState {
        case .allowed: L10n.text("settings.reminders.permission.allowed")
        case .denied: L10n.text("settings.reminders.permission.denied")
        case .unknown: L10n.text("settings.reminders.permission.notRequested")
        }
    }

    private var permissionBadgeColor: Color {
        switch permissionState {
        case .allowed: .green
        case .denied: .red
        case .unknown: .secondary
        }
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
        return L10n.text("settings.version.value", version, build)
    }

    private func updateReminder(_ kind: ReminderKind, enabled: Bool) {
        switch kind {
        case .insurance: settings.insuranceRemindersEnabled = enabled
        case .maintenance: settings.maintenanceRemindersEnabled = enabled
        }

        Task {
            isSynchronizing = true
            defer { isSynchronizing = false }

            do {
                if enabled, await reminderService.permissionState() != .allowed {
                    let granted = try await reminderService.requestPermission()
                    guard granted else {
                        disable(kind)
                        permissionState = .denied
                        return
                    }
                }

                permissionState = await reminderService.permissionState()
                try await reminderService.synchronize()
            } catch {
                disable(kind)
                errorMessage = error.localizedDescription
                permissionState = await reminderService.permissionState()
            }
        }
    }

    private func disable(_ kind: ReminderKind) {
        switch kind {
        case .insurance: settings.insuranceRemindersEnabled = false
        case .maintenance: settings.maintenanceRemindersEnabled = false
        }
    }

    private func refreshAndSynchronize() async {
        isSynchronizing = true
        defer { isSynchronizing = false }
        permissionState = await reminderService.permissionState()

        do {
            try await reminderService.synchronize()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func synchronizeReminders() {
        Task {
            do {
                try await reminderService.synchronize()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

private enum ReminderKind {
    case insurance
    case maintenance
}

private struct SettingsCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(16)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.04), radius: 12, y: 5)
    }
}

private struct SettingsIcon: View {
    let symbol: String
    let colors: [Color]

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 36, height: 36)
            .background(
                LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
    }
}

private struct ReminderToggleRow: View {
    let symbol: String
    let title: String
    let subtitle: String
    let tint: Color
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 32, height: 32)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 9))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color("primary"))
        }
    }
}

private struct SettingsNavigationRow: View {
    let symbol: String
    let title: String
    let value: String?
    let tint: Color
    let showsChevron: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(tint.gradient, in: RoundedRectangle(cornerRadius: 9))

            Text(title)
                .font(.body)
                .foregroundStyle(.primary)

            Spacer()

            if let value {
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
        }
        .contentShape(Rectangle())
        .padding(.vertical, 10)
    }
}
