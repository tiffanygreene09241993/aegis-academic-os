import WidgetKit
import SwiftUI

struct CountdownEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct CountdownProvider: TimelineProvider {
    func placeholder(in context: Context) -> CountdownEntry {
        CountdownEntry(date: .now, snapshot: .fallback)
    }

    func getSnapshot(in context: Context, completion: @escaping (CountdownEntry) -> Void) {
        completion(CountdownEntry(date: .now, snapshot: WidgetSnapshot.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CountdownEntry>) -> Void) {
        let snapshot = WidgetSnapshot.load()
        // One entry per midnight for the next week; the day count is all that changes.
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: .now)
        var entries = [CountdownEntry(date: .now, snapshot: snapshot)]
        for day in 1...7 {
            if let d = calendar.date(byAdding: .day, value: day, to: start) {
                entries.append(CountdownEntry(date: d, snapshot: snapshot))
            }
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct CountdownWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: CountdownEntry

    private var days: Int { entry.snapshot.daysRemaining(from: entry.date) }
    private var progress: Double {
        entry.snapshot.requiredCredits > 0
            ? min(1, Double(entry.snapshot.earnedCredits) / Double(entry.snapshot.requiredCredits)) : 0
    }

    var body: some View {
        switch family {
        case .accessoryCircular:
            Gauge(value: progress) {
                Image(systemName: "graduationcap.fill")
            } currentValueLabel: {
                Text("\(days)").monospacedDigit()
            }
            .gaugeStyle(.accessoryCircular)
            .accessibilityLabel("\(days) days to commencement")
        case .accessoryInline:
            Label("\(days) days to commencement", systemImage: "graduationcap.fill")
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Label("Commencement", systemImage: "graduationcap.fill")
                    .font(.headline)
                    .widgetAccentable()
                Text("\(days) days to go").font(.body.monospacedDigit())
                Text("\(entry.snapshot.earnedCredits)/\(entry.snapshot.requiredCredits) credits applied")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        default:
            VStack(alignment: .leading, spacing: 4) {
                Image(systemName: "graduationcap.fill")
                    .foregroundStyle(Color("AccentColor"))
                    .accessibilityHidden(true)
                Spacer(minLength: 0)
                Text("\(days)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color("AccentColor"))
                    .minimumScaleFactor(0.5)
                Text("days to commencement")
                    .font(.caption)
                    .foregroundStyle(Color("TextSecondary"))
                ProgressView(value: progress).tint(Color("AccentColor"))
            }
            .accessibilityElement(children: .combine)
        }
    }
}

struct AegisCountdownWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "AegisCountdown", provider: CountdownProvider()) { entry in
            CountdownWidgetView(entry: entry)
                .containerBackground(for: .widget) { Color("WidgetBackground") }
        }
        .configurationDisplayName("Commencement Countdown")
        .description("Days until commencement and your credit progress.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .systemSmall])
    }
}

@main
struct AegisWidgetBundle: WidgetBundle {
    var body: some Widget {
        AegisCountdownWidget()
    }
}

#Preview(as: .accessoryRectangular) {
    AegisCountdownWidget()
} timeline: {
    CountdownEntry(date: .now, snapshot: .fallback)
}

#Preview(as: .systemSmall) {
    AegisCountdownWidget()
} timeline: {
    CountdownEntry(date: .now, snapshot: .fallback)
}
