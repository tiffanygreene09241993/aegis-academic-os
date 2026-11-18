import SwiftUI

/// Two-segment progress ring matching the audit's credit tracker:
/// completed credits applied to the degree (accent) + in progress (sky).
struct CreditRing: View {
    let earned: Double
    let active: Double
    let required: Int
    var lineWidth: CGFloat = 16

    private var earnedFraction: Double { required > 0 ? min(1, earned / Double(required)) : 0 }
    private var activeEnd: Double { required > 0 ? min(1, (earned + active) / Double(required)) : 0 }

    var body: some View {
        ZStack {
            Circle().stroke(Color.aegisHairline, lineWidth: lineWidth)
            Circle()
                .trim(from: earnedFraction, to: activeEnd)
                .stroke(Color.aegisSky.opacity(0.7), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Circle()
                .trim(from: 0, to: earnedFraction)
                .stroke(Color.aegisAccent, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(color: Color.aegisGlow, radius: 8)
            VStack(spacing: 0) {
                Text("\(Int((activeEnd * 100).rounded()))%")
                    .font(.title.bold().monospacedDigit())
                    .foregroundStyle(Color.aegisText)
                Text("applied")
                    .font(.caption)
                    .foregroundStyle(Color.aegisTextSecondary)
            }
            .minimumScaleFactor(0.6)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Credit progress")
        .accessibilityValue("\(CreditFormat.string(earned + active)) of \(required) credits applied, including \(CreditFormat.string(active)) in progress")
    }
}

/// Small labeled number used in stat grids.
struct StatTile: View {
    let value: String
    let label: String
    var tint: Color = .aegisText

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(.title2.bold().monospacedDigit()).foregroundStyle(tint)
            Text(label).font(.caption).foregroundStyle(Color.aegisTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
