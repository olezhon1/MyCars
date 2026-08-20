import Foundation
import UserNotifications

enum ReminderPermissionState: Equatable {
    case unknown
    case allowed
    case denied
}

@MainActor
final class ReminderService {
    private enum Identifier {
        static let insurancePrefix = "mycars.insurance."
        static let maintenancePrefix = "mycars.maintenance."
        static let scheduledKey = "mycars.reminders.scheduledIdentifiers"
    }

    private let repository: any CarRepository
    private let settings: AppSettings
    private let center: UNUserNotificationCenter
    private let defaults: UserDefaults
    private let calendar: Calendar

    init(
        repository: any CarRepository,
        settings: AppSettings,
        center: UNUserNotificationCenter = .current(),
        defaults: UserDefaults = .standard,
        calendar: Calendar = .current
    ) {
        self.repository = repository
        self.settings = settings
        self.center = center
        self.defaults = defaults
        self.calendar = calendar
    }

    func permissionState() async -> ReminderPermissionState {
        switch await center.notificationSettings().authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return .allowed
        case .denied:
            return .denied
        case .notDetermined:
            return .unknown
        @unknown default:
            return .unknown
        }
    }

    func requestPermission() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func synchronize() async throws {
        guard await permissionState() == .allowed else { return }

        let cars = try repository.fetchCars()
        var desired: [String: UNNotificationRequest] = [:]

        if settings.insuranceRemindersEnabled {
            desired.merge(insuranceRequests(for: cars)) { _, new in new }
        }

        if settings.maintenanceRemindersEnabled {
            desired.merge(maintenanceRequests(for: cars)) { _, new in new }
        }

        let pending = await center.pendingNotificationRequests()
        let managedPending = pending.filter { isManaged($0.identifier) }
        let obsoleteIDs = managedPending.map(\.identifier).filter { desired[$0] == nil }
        center.removePendingNotificationRequests(withIdentifiers: obsoleteIDs)

        let delivered = await center.deliveredNotifications()
        let obsoleteDeliveredIDs = delivered.map { $0.request.identifier }
            .filter { isManaged($0) && desired[$0] == nil }
        center.removeDeliveredNotifications(withIdentifiers: obsoleteDeliveredIDs)

        let existingIDs = Set(managedPending.map(\.identifier))
        var scheduledIDs = Set(defaults.stringArray(forKey: Identifier.scheduledKey) ?? [])
        scheduledIDs.formIntersection(desired.keys)

        for (identifier, request) in desired {
            if existingIDs.contains(identifier) {
                try await center.add(request)
            } else if !scheduledIDs.contains(identifier) {
                try await center.add(request)
                scheduledIDs.insert(identifier)
            }
        }

        defaults.set(Array(scheduledIDs).sorted(), forKey: Identifier.scheduledKey)
    }

    private func insuranceRequests(for cars: [Car]) -> [String: UNNotificationRequest] {
        let now = Date()
        var requests: [String: UNNotificationRequest] = [:]

        for car in cars {
            for insurance in car.insurances where insurance.endDate >= now {
                let identifier = "\(Identifier.insurancePrefix)\(insurance.id.uuidString).\(settings.insuranceLeadDays)"
                let content = UNMutableNotificationContent()
                content.title = L10n.text("notification.insurance.title")
                content.body = L10n.text(
                    "notification.insurance.body",
                    "\(car.brand) \(car.model)",
                    insurance.endDate.formatted(
                        .dateTime.day().month(.abbreviated).year().locale(L10n.locale)
                    )
                )
                content.sound = .default
                content.userInfo = ["carID": car.id.uuidString, "kind": "insurance"]

                let reminderDay = calendar.date(
                    byAdding: .day,
                    value: -settings.insuranceLeadDays,
                    to: calendar.startOfDay(for: insurance.endDate)
                ) ?? insurance.endDate
                let deliveryDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: reminderDay) ?? reminderDay
                let trigger: UNNotificationTrigger

                if deliveryDate > now {
                    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: deliveryDate)
                    trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                } else {
                    trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                }

                requests[identifier] = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            }
        }

        return requests
    }

    private func maintenanceRequests(for cars: [Car]) -> [String: UNNotificationRequest] {
        var requests: [String: UNNotificationRequest] = [:]

        for car in cars {
            guard
                let interval = car.estimatedMaintenanceInterval,
                let lastMileage = car.maintenanceHistory
                    .filter({ $0.type == .scheduled })
                    .map(\.mileage)
                    .max()
            else { continue }

            let targetMileage = lastMileage + interval
            let remaining = targetMileage - car.currentMileage
            guard remaining <= settings.maintenanceThreshold else { continue }

            let identifier = "\(Identifier.maintenancePrefix)\(car.id.uuidString).\(targetMileage)"
            let content = UNMutableNotificationContent()
            content.title = L10n.text("notification.maintenance.title")
            if remaining > 0 {
                content.body = L10n.text(
                    "notification.maintenance.body.soon",
                    "\(car.brand) \(car.model)",
                    remaining
                )
            } else {
                content.body = L10n.text(
                    "notification.maintenance.body.overdue",
                    "\(car.brand) \(car.model)",
                    abs(remaining)
                )
            }
            content.sound = .default
            content.userInfo = ["carID": car.id.uuidString, "kind": "maintenance"]
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            requests[identifier] = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        }

        return requests
    }

    private func isManaged(_ identifier: String) -> Bool {
        identifier.hasPrefix(Identifier.insurancePrefix) || identifier.hasPrefix(Identifier.maintenancePrefix)
    }
}
