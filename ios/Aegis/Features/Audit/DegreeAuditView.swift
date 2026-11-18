import SwiftUI

struct DegreeAuditView: View {
    @Environment(ProgramStore.self) private var store
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            Group {
                if let program = store.program {
                    if program.categories.isEmpty {
                        EmptyStateView(title: "No requirements yet",
                                       message: "Add requirement categories, like General Education or Major Core, in Settings.",
                                       systemImage: "checklist",
                                       actionTitle: "Open Settings") { showSettings = true }
                    } else {
                        list(program)
                    }
                } else {
                    LoadingSkeleton()
                }
            }
            .aegisListStyle()
            .navigationTitle("Degree Audit")
            .toolbar { SettingsToolbarItem(isPresented: $showSettings) }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .navigationDestination(for: RequirementCategory.self) { category in
                RequirementDetailView(categoryID: category.id)
            }
        }
    }

    private func list(_ program: Program) -> some View {
        List {
            if store.saveError != nil {
                SaveErrorBanner().listRowBackground(Color.clear).listRowInsets(EdgeInsets())
            }
            Section {
                AuditRow(label: "Applied to degree", value: "\(CreditFormat.string(program.appliedCredits)) / \(program.requiredCredits)",
                         symbol: "checkmark.seal.fill", tint: .aegisAccent)
                AuditRow(label: "In progress", value: CreditFormat.string(program.activeCredits), symbol: "clock.fill", tint: .aegisSky)
                AuditRow(label: "Still needed", value: CreditFormat.string(program.remainingPlannedCredits), symbol: "calendar", tint: .aegisSkySoft)
                if program.unplannedCredits > 0 {
                    AuditRow(label: "Not yet planned", value: CreditFormat.string(program.unplannedCredits), symbol: "questionmark.circle", tint: .libertyText)
                }
                AuditRow(label: "Earned (transcript)", value: CreditFormat.string(program.earnedCredits), symbol: "doc.text", tint: .aegisText)
                let transfer = program.credits(for: .transfer)
                if transfer > 0 {
                    AuditRow(label: "Institutional · Transfer",
                             value: "\(CreditFormat.string(program.credits(for: .institutional))) · \(CreditFormat.string(transfer))",
                             symbol: "building.2", tint: .aegisSkySoft)
                }
            } header: {
                Text("Credits")
            } footer: {
                creditsFooter(program)
            }
            .listRowBackground(Color.aegisSurface)

            if let checks = program.graduationRequirements, !checks.isEmpty {
                Section("Graduation requirements") {
                    ForEach(checks) { GraduationRequirementRow(requirement: $0) }
                }
                .listRowBackground(Color.aegisSurface)
            }

            Section("Requirements") {
                ForEach(program.categories) { category in
                    NavigationLink(value: category) {
                        RequirementRow(category: category, program: program)
                    }
                }
            }
            .listRowBackground(Color.aegisSurface)

            if let note = program.dataNote {
                Section { } footer: { Text(note) }
            }
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    private func creditsFooter(_ program: Program) -> some View {
        let notApplied = program.nonApplicableCredits ?? 0
        if notApplied > 0 {
            Text("Applied = \(CreditFormat.string(program.appliedEarnedCredits)) completed credits the audit counts + \(CreditFormat.string(program.activeCredits)) in progress. \(notApplied) earned credits (extra transfer electives) don't apply to requirements.")
        } else if program.unitemizedEarnedCredits > 0 {
            Text("Earned includes \(program.unitemizedEarnedCredits) credits that aren't listed course by course.")
        }
    }
}

private struct GraduationRequirementRow: View {
    let requirement: GraduationRequirement

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.m) {
            Image(systemName: icon)
                .foregroundStyle(requirement.isMet == true ? Color.aegisAccent : Color.aegisTextSecondary)
                .frame(width: 24)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(requirement.name).foregroundStyle(Color.aegisText)
                Group {
                    if let current = requirement.current {
                        Text("\(current) of \(requirement.required)")
                    } else {
                        Text(requirement.required)
                    }
                }
                .font(.subheadline)
                .foregroundStyle(Color.aegisTextSecondary)
            }
        }
        .frame(minHeight: 44)
        .accessibilityElement(children: .combine)
        .accessibilityValue(requirement.isMet == true ? "Met" : "Not yet met")
    }

    private var icon: String {
        requirement.isMet == true ? "checkmark.circle.fill" : "circle.dashed"
    }
}

private struct AuditRow: View {
    let label: String
    let value: String
    let symbol: String
    let tint: Color

    var body: some View {
        LabeledContent {
            Text(value).font(.body.monospacedDigit().weight(.semibold)).foregroundStyle(Color.aegisText)
        } label: {
            Label {
                Text(label).foregroundStyle(Color.aegisText)
            } icon: {
                Image(systemName: symbol).foregroundStyle(tint)
            }
        }
        .frame(minHeight: 44)
        .accessibilityElement(children: .combine)
    }
}

struct RequirementRow: View {
    let category: RequirementCategory
    let program: Program

    var body: some View {
        let listed = program.listedCredits(in: category)
        let applied = program.appliedCredits(in: category)
        let done = program.listedCredits(in: category, statuses: [.completed])
        HStack(spacing: Spacing.m) {
            Image(systemName: category.symbol)
                .font(.title3)
                .foregroundStyle(Color.aegisAccent)
                .frame(width: 44, height: 44)
                .background(Color.aegisAccent.opacity(0.12), in: .rect(cornerRadius: 10))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name).font(.headline).foregroundStyle(Color.aegisText)
                Group {
                    if let required = category.requiredCredits {
                        Text("\(CreditFormat.string(applied)) of \(required) credits applied · \(CreditFormat.string(done)) complete")
                    } else if listed > 0 {
                        Text("\(CreditFormat.string(listed)) credits listed · \(CreditFormat.string(done)) complete")
                    } else {
                        Text("No courses listed yet")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(Color.aegisTextSecondary)
                .lineLimit(2)
                if let required = category.requiredCredits, required > 0 {
                    ProgressView(value: min(1, applied / Double(required)))
                        .tint(.aegisAccent)
                        .accessibilityHidden(true)
                }
            }
        }
        .padding(.vertical, Spacing.xs)
        .accessibilityElement(children: .combine)
    }
}

struct RequirementDetailView: View {
    let categoryID: String
    @Environment(ProgramStore.self) private var store
    @State private var editing: Course?
    @State private var adding = false

    var body: some View {
        if let program = store.program, let category = program.categories.first(where: { $0.id == categoryID }) {
            let courses = program.courses(in: category)
            Group {
                if courses.isEmpty {
                    EmptyStateView(title: "No courses here yet",
                                   message: "Add a course you've taken or plan to take for \(category.name).",
                                   systemImage: category.symbol,
                                   actionTitle: "Add Course") { adding = true }
                } else {
                    List {
                        if let summary = category.summary {
                            Section { Text(summary).foregroundStyle(Color.aegisTextSecondary) }
                                .listRowBackground(Color.aegisSurface)
                        }
                        ForEach(CourseStatus.allCases) { status in
                            let group = courses.filter { $0.status == status }
                            if !group.isEmpty {
                                Section(status.label) {
                                    ForEach(group) { course in
                                        Button { editing = course } label: { CourseRow(course: course) }
                                            .foregroundStyle(Color.aegisText)
                                    }
                                }
                                .listRowBackground(Color.aegisSurface)
                            }
                        }
                    }
                }
            }
            .aegisListStyle()
            .navigationTitle(category.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { adding = true } label: { Image(systemName: "plus") }
                        .accessibilityLabel("Add course")
                }
            }
            .sheet(item: $editing) { CourseEditorView(existing: $0) }
            .sheet(isPresented: $adding) { CourseEditorView(existing: nil, defaultCategoryID: categoryID) }
        } else {
            EmptyStateView(title: "Requirement not found", message: "It may have been removed in Settings.",
                           systemImage: "questionmark.folder")
        }
    }
}

#Preview("Audit · Dark") {
    DegreeAuditView().environment(ProgramStore.preview()).environmentObject(MotionManager())
        .preferredColorScheme(.dark)
}

#Preview("Audit · Light, AX3") {
    DegreeAuditView().environment(ProgramStore.preview()).environmentObject(MotionManager())
        .preferredColorScheme(.light)
        .dynamicTypeSize(.accessibility3)
}

#Preview("Requirement · Empty") {
    NavigationStack { RequirementDetailView(categoryID: "cognate") }
        .environment(ProgramStore.preview())
}
