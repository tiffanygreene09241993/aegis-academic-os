import Foundation
import UserNotifications

/// Local-only commencement reminders. Permission is requested only after the user reads a pre-prompt.
enum NotificationScheduler {
    static let reminderDays = [100, 30, 7, 1]
    private static let idPrefix = "aegis.commencement."

    static func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    /// Returns true when the user allowed notifications.
    static func requestAuthorization() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    static func scheduleReminders(for program: Program, now: Date = Date()) async {
        let center = UNUserNotificationCenter.current()
        await cancelReminders()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = program.commencementTimeZone
        for days in reminderDays {
            guard let day = calendar.date(byAdding: .day, value: -days, to: program.commencement),
                  let fireDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: day),
                  fireDate > now else { continue }
            let content = UNMutableNotificationContent()
            content.title = days == 1 ? "Commencement is tomorrow" : "\(days) days to commencement"
            content.body = "\(CreditFormat.string(program.appliedCredits)) of \(program.requiredCredits) credits applied. Keep going."
            content.sound = .default
            let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            try? await center.add(UNNotificationRequest(identifier: idPrefix + "\(days)", content: content, trigger: trigger))
        }
    }

    static func cancelReminders() async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: reminderDays.map { idPrefix + "\($0)" })
    }
}
