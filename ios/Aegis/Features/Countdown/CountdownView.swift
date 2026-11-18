import SwiftUI

struct CountdownView: View {
    @Environment(ProgramStore.self) private var store
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showSettings = false
    @State private var showConferral = false
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        NavigationStack {
            Group {
                if let program = store.program {
                    content(program)
                } else {
                    LoadingSkeleton()
                }
            }
            .background(AegisBackground())
            .navigationTitle("Countdown")
            .toolbar { SettingsToolbarItem(isPresented: $showSettings) }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .fullScreenCover(isPresented: $showConferral) {
                if let program = store.program { ConferralCelebrationView(program: program) }
            }
        }
    }

    private func content(_ program: Program) -> some View {
        ScrollView {
            VStack(spacing: Spacing.m) {
                SaveErrorBanner()
                countdownCard(program)
                progressCard(program)
                milestoneCard(program)
                Button {
                    showConferral = true
                } label: {
                    Label("Preview Conferral", systemImage: "sparkles")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .accessibilityHint("Opens a full-screen graduation celebration")
            }
            .padding(Spacing.m)
        }
    }

    // MARK: Cards

    private func countdownCard(_ program: Program) -> some View {
        // Reduce Motion: update once a minute instead of every second.
        TimelineView(.periodic(from: .now, by: reduceMotion ? 60 : 1)) { context in
            let parts = CountdownParts(from: context.date, to: program.commencement)
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text(parts.isComplete ? "Commencement day" : "Until commencement")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.aegisTextSecondary)
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline, spacing: Spacing.m) { units(parts) }
                    VStack(alignment: .leading, spacing: Spacing.xs) { units(parts) }
                }
                Text(program.commencement.formatted(
                    Date.FormatStyle(date: .complete, time: .shortened, timeZone: program.commencementTimeZone)))
                    .font(.footnote)
                    .foregroundStyle(Color.aegisTextSecondary)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Countdown to commencement")
            .accessibilityValue("\(parts.days) days, \(parts.hours) hours, \(parts.minutes) minutes")
        }
        .glassCard(tint: Color.aegisAccent.opacity(0.08))
        .contentShape(.rect)
        .onTapGesture { showConferral = true }
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Double-tap to preview the conferral celebration")
    }

    @ViewBuilder
    private func units(_ parts: CountdownParts) -> some View {
        CountdownUnit(value: parts.days, label: "days", prominent: true)
        CountdownUnit(value: parts.hours, label: "hrs")
        CountdownUnit(value: parts.minutes, label: "min")
        if !reduceMotion { CountdownUnit(value: parts.seconds, label: "sec") }
    }

    private func progressCard(_ program: Program) -> some View {
        // Stack vertically at accessibility text sizes so nothing clips.
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Spacing.l))
            : AnyLayout(HStackLayout(spacing: Spacing.l))
        return layout {
            CreditRing(earned: program.appliedEarnedCredits, active: program.activeCredits, required: program.requiredCredits)
                .frame(width: 128, height: 128)
            VStack(alignment: .leading, spacing: Spacing.s) {
                StatTile(value: "\(CreditFormat.string(program.appliedCredits))/\(program.requiredCredits)", label: "Applied to degree", tint: .aegisAccent)
                StatTile(value: CreditFormat.string(program.activeCredits), label: "In progress", tint: .aegisSky)
                StatTile(value: CreditFormat.string(program.creditsRemainingAfterInProgress), label: "Still needed")
            }
        }
        .glassCard()
    }

    @ViewBuilder
    private func milestoneCard(_ program: Program) -> some View {
        if let next = program.nextMilestone {
            HStack(spacing: Spacing.m) {
                Image(systemName: next.symbol)
                    .font(.title3)
                    .foregroundStyle(Color.aegisAccent)
                    .frame(width: 44, height: 44)
                    .glassEffect(.regular, in: .circle)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Next milestone").font(.caption).foregroundStyle(Color.aegisTextSecondary)
                    Text(next.title).font(.headline).foregroundStyle(Color.aegisText)
                    if let detail = next.detail {
                        Text(detail).font(.subheadline).foregroundStyle(Color.aegisTextSecondary).lineLimit(2)
                    }
                }
                Spacer(minLength: 0)
                Button {
                    store.toggleMilestone(next)
                } label: {
                    Image(systemName: "checkmark.circle")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Mark \(next.title) complete")
            }
            .glassCard()
            .sensoryFeedback(.success, trigger: program.milestones.filter(\.isComplete).count)
        } else {
            EmptyStateView(title: "All milestones done", message: "Add milestones in Settings to keep tracking what's next.",
                           systemImage: "flag.checkered")
                .glassCard()
        }
    }
}

private struct CountdownUnit: View {
    let value: Int
    let label: String
    var prominent = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text("\(value)")
                .font(prominent ? .system(.largeTitle, design: .rounded, weight: .bold) : .system(.title, design: .rounded, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(prominent ? Color.aegisAccent : Color.aegisText)
                .contentTransition(.numericText(countsDown: true))
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.aegisTextSecondary)
        }
    }
}

#Preview("Countdown · Dark") {
    CountdownView().environment(ProgramStore.preview()).environmentObject(MotionManager())
        .preferredColorScheme(.dark)
}

#Preview("Countdown · Light") {
    CountdownView().environment(ProgramStore.preview()).environmentObject(MotionManager())
        .preferredColorScheme(.light)
}

#Preview("Countdown · AX5 type") {
    CountdownView().environment(ProgramStore.preview()).environmentObject(MotionManager())
        .dynamicTypeSize(.accessibility5)
}
