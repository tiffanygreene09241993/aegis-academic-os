import Foundation

/// The small slice of data the lock-screen widget needs, shared through an App Group.
struct WidgetSnapshot: Codable, Equatable {
    var commencement: Date
    /// Credits applied to the degree (the audit tracker's numerator, includes in-progress).
    var earnedCredits: Int
    var requiredCredits: Int
    var programTitle: String

    static let appGroupID = "group.com.tiffanygreene.aegis"
    private static let key = "widgetSnapshot.v1"

    /// Used before the app has saved anything (Aug 20, 2027 12:00 AM America/New_York).
    static let fallback = WidgetSnapshot(
        commencement: Date(timeIntervalSince1970: 1_818_734_400),
        earnedCredits: 94, requiredCredits: 121, programTitle: "Commencement")

    static func load() -> WidgetSnapshot {
        guard let data = UserDefaults(suiteName: appGroupID)?.data(forKey: key),
              let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data) else {
            return fallback
        }
        return snapshot
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults(suiteName: Self.appGroupID)?.set(data, forKey: Self.key)
    }

    func daysRemaining(from now: Date = Date()) -> Int {
        max(0, Int(ceil(commencement.timeIntervalSince(now) / 86_400)))
    }
}
