import SwiftUI

struct HonorsView: View {
    @Environment(ProgramStore.self) private var store
    @State private var showSettings = false
    @ScaledMetric(relativeTo: .largeTitle) private var gpaSize: CGFloat = 56

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
            .navigationTitle("Honors")
            .toolbar { SettingsToolbarItem(isPresented: $showSettings) }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .navigationDestination(for: Honor.self) { HonorDetailView(honor: $0) }
        }
    }

    private func content(_ program: Program) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.m) {
                SaveErrorBanner()
                gpaCard(program)
                latinTrack(program)

                sectionHeader("Honor societies")
                if program.honors.isEmpty {
                    EmptyStateView(title: "No societies yet",
                                   message: "Add honor societies you've joined in Settings.",
                                   systemImage: "rosette",
                                   actionTitle: "Open Settings") { showSettings = true }
                        .glassCard()
                } else {
                    GlassEffectContainer(spacing: Spacing.s) {
                        VStack(spacing: Spacing.s) {
                            ForEach(program.honors) { honor in
                                NavigationLink(value: honor) { HonorRow(honor: honor) }
                                    .buttonStyle(.plain)
                            }
                        }
                    }
                }

                if !program.regalia.isEmpty {
                    sectionHeader("Commencement regalia")
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        ForEach(program.regalia) { item in
                            HStack(alignment: .top, spacing: Spacing.m) {
                                Image(systemName: item.id == "mortarboard" ? "graduationcap.fill" : "seal.fill")
                                    .foregroundStyle(Color.aegisAccent)
                                    .frame(width: 28)
                                    .accessibilityHidden(true)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.item).font(.headline).foregroundStyle(Color.aegisText)
                                    Text(item.distinction).font(.subheadline).foregroundStyle(Color.aegisTextSecondary)
                                    Text(item.status).font(.caption.weight(.semibold)).foregroundStyle(Color.aegisSky)
                                }
                            }
                            .accessibilityElement(children: .combine)
                        }
                    }
                    .glassCard()
                }
            }
            .padding(Spacing.m)
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.title3.bold())
            .foregroundStyle(Color.aegisText)
            .padding(.top, Spacing.s)
            .accessibilityAddTraits(.isHeader)
    }

    private func gpaCard(_ program: Program) -> some View {
        HStack(alignment: .center, spacing: Spacing.m) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Cumulative GPA").font(.subheadline).foregroundStyle(Color.aegisTextSecondary)
                Text(program.cumulativeGPA, format: .number.precision(.fractionLength(2)))
                    .font(.system(size: gpaSize, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color.aegisAccent)
                    .minimumScaleFactor(0.5)
                    .shadow(color: .aegisGlow, radius: 10)
                Text("on a \(program.gpaScale, format: .number.precision(.fractionLength(1))) scale")
                    .font(.footnote).foregroundStyle(Color.aegisTextSecondary)
            }
            Spacer(minLength: 0)
            if let honor = program.projectedLatinHonor {
                VStack(spacing: Spacing.xs) {
                    Image(systemName: "laurel.leading.laurel.trailing")
                        .font(.largeTitle)
                        .foregroundStyle(Color.aegisAccent)
                        .accessibilityHidden(true)
                    Text("Projected").font(.caption).foregroundStyle(Color.aegisTextSecondary)
                    Text(honor.name).font(.headline).multilineTextAlignment(.center).foregroundStyle(Color.aegisText)
                }
            }
        }
        .glassCard(tint: Color.aegisAccent.opacity(0.08))
        .accessibilityElement(children: .combine)
    }

    private func latinTrack(_ program: Program) -> some View {
        let thresholds = program.latinHonors.sorted { $0.minimumGPA > $1.minimumGPA }
        return VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Latin honors track").font(.headline).foregroundStyle(Color.aegisText)
            if thresholds.isEmpty {
                Text("Add your school's Latin honors GPA thresholds in Settings.")
                    .font(.subheadline).foregroundStyle(Color.aegisTextSecondary)
            }
            ForEach(thresholds) { t in
                let met = program.cumulativeGPA >= t.minimumGPA
                HStack {
                    Image(systemName: met ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(met ? Color.aegisAccent : Color.aegisTextSecondary)
                        .accessibilityHidden(true)
                    Text(t.name).foregroundStyle(Color.aegisText)
                    Spacer()
                    Text("\(t.minimumGPA, format: .number.precision(.fractionLength(2)))+")
                        .monospacedDigit()
                        .foregroundStyle(Color.aegisTextSecondary)
                }
                .frame(minHeight: 44)
                .accessibilityElement(children: .combine)
                .accessibilityValue(met ? "Met" : "Not met")
            }
            Text("Projection based on your current GPA. Your school confirms final honors.")
                .font(.caption).foregroundStyle(Color.aegisTextSecondary)
        }
        .glassCard()
    }
}

private struct HonorRow: View {
    let honor: Honor

    var body: some View {
        HStack(spacing: Spacing.m) {
            Image(systemName: "rosette")
                .font(.title2)
                .foregroundStyle(Color.aegisAccent)
                .frame(width: 44, height: 44)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(honor.name).font(.headline).foregroundStyle(Color.aegisText)
                if let chapter = honor.chapter {
                    Text(chapter).font(.subheadline).foregroundStyle(Color.aegisTextSecondary)
                }
                Text([honor.status, honor.inducted].compactMap { $0 }.joined(separator: " · "))
                    .font(.caption.weight(.semibold)).foregroundStyle(Color.aegisSky)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.aegisTextSecondary)
                .accessibilityHidden(true)
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: Radius.card))
        .accessibilityElement(children: .combine)
    }
}

struct HonorDetailView: View {
    let honor: Honor

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(honor.name).font(.title2.bold())
                    if let chapter = honor.chapter { Text(chapter).foregroundStyle(Color.aegisTextSecondary) }
                }
                .padding(.vertical, Spacing.xs)
                if let summary = honor.summary { Text(summary) }
            }
            Section("Details") {
                LabeledContent("Status", value: honor.status)
                if let inducted = honor.inducted { LabeledContent("Inducted", value: inducted) }
                if let discipline = honor.discipline { LabeledContent("Discipline", value: discipline) }
                if let requirement = honor.requirement { LabeledContent("Requirement", value: requirement) }
                if let cords = honor.regaliaCords { LabeledContent("Regalia cords", value: cords) }
            }
        }
        .listRowBackground(Color.aegisSurface)
        .aegisListStyle()
        .navigationTitle("Society")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Honors · Dark") {
    HonorsView().environment(ProgramStore.preview()).environmentObject(MotionManager())
        .preferredColorScheme(.dark)
}

#Preview("Honors · Light, AX5") {
    HonorsView().environment(ProgramStore.preview()).environmentObject(MotionManager())
        .preferredColorScheme(.light)
        .dynamicTypeSize(.accessibility5)
}
