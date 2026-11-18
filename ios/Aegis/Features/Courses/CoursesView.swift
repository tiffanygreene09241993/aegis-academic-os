import SwiftUI

struct CoursesView: View {
    @Environment(ProgramStore.self) private var store
    @State private var showSettings = false
    @State private var adding = false
    @State private var editing: Course?
    @State private var undoTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            Group {
                if let program = store.program {
                    if program.courses.isEmpty {
                        EmptyStateView(title: "No courses yet",
                                       message: "Add the courses you're taking this term and the ones still ahead.",
                                       systemImage: "books.vertical",
                                       actionTitle: "Add Course") { adding = true }
                    } else {
                        list(program)
                    }
                } else {
                    LoadingSkeleton()
                }
            }
            .aegisListStyle()
            .navigationTitle("Courses")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { adding = true } label: { Image(systemName: "plus") }
                        .accessibilityLabel("Add course")
                }
                SettingsToolbarItem(isPresented: $showSettings)
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .sheet(isPresented: $adding) { CourseEditorView(existing: nil) }
            .sheet(item: $editing) { CourseEditorView(existing: $0) }
            .safeAreaInset(edge: .bottom) { undoBar }
            .sensoryFeedback(.warning, trigger: store.recentlyDeleted?.course.id)
        }
    }

    private func list(_ program: Program) -> some View {
        List {
            if store.saveError != nil {
                SaveErrorBanner().listRowBackground(Color.clear).listRowInsets(EdgeInsets())
            }
            let terms = program.inProgressTerms
            if terms.isEmpty {
                section("In progress", courses: [], program: program,
                        empty: "Nothing in progress. Tap + to add this term's courses.")
            }
            ForEach(terms, id: \.self) { term in
                section("In progress · \(term)",
                        courses: program.courses.filter { $0.status == .inProgress && $0.term == term },
                        program: program, empty: nil)
            }
            section("Still needed", courses: program.courses.filter { $0.status == .planned },
                    program: program, empty: "Nothing left to schedule.")
            let completed = program.courses.filter { $0.status == .completed }
            section("Completed · \(program.student.institution)",
                    courses: completed.filter { $0.source == .institutional }, program: program, empty: nil)
            section("Completed · Transfer",
                    courses: completed.filter { $0.source == .transfer }, program: program, empty: nil)
            section("Completed", courses: completed.filter { $0.source == nil }, program: program, empty: nil)
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    private func section(_ title: String, courses: [Course], program: Program, empty: String?) -> some View {
        if !courses.isEmpty || empty != nil {
            Section {
                if courses.isEmpty, let empty {
                    Text(empty).font(.subheadline).foregroundStyle(Color.aegisTextSecondary)
                }
                ForEach(courses) { course in
                    Button { editing = course } label: { CourseRow(course: course) }
                        .foregroundStyle(Color.aegisText)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                delete(course)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .accessibilityAction(named: "Delete") { delete(course) }
                }
            } header: {
                HStack {
                    Text(title)
                    Spacer()
                    Text("\(CreditFormat.string(courses.reduce(0) { $0 + $1.credits })) cr").monospacedDigit()
                }
            }
            .listRowBackground(Color.aegisSurface)
        }
    }

    private func delete(_ course: Course) {
        store.delete(course)
        undoTask?.cancel()
        undoTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(5))
            if !Task.isCancelled { store.clearUndo() }
        }
    }

    @ViewBuilder
    private var undoBar: some View {
        if let deleted = store.recentlyDeleted {
            HStack {
                Text("Deleted \(deleted.course.code)").font(.subheadline)
                Spacer()
                Button("Undo") { store.undoDelete() }
                    .font(.subheadline.bold())
                    .frame(minWidth: 44, minHeight: 44)
            }
            .padding(.horizontal, Spacing.m)
            .glassEffect(.regular, in: .capsule)
            .padding(Spacing.m)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .accessibilityElement(children: .combine)
        }
    }
}

struct CourseRow: View {
    let course: Course

    var body: some View {
        HStack(spacing: Spacing.m) {
            Text(course.code)
                .font(.caption.weight(.bold).monospaced())
                .foregroundStyle(Color.aegisAccent)
                .frame(minWidth: 72, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text(course.title).font(.body).foregroundStyle(Color.aegisText)
                Text(course.term).font(.footnote).foregroundStyle(Color.aegisTextSecondary).lineLimit(2)
            }
            Spacer(minLength: Spacing.s)
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(CreditFormat.string(course.credits)) cr").font(.footnote.monospacedDigit()).foregroundStyle(Color.aegisTextSecondary)
                if let grade = course.grade {
                    Text(grade).font(.caption).foregroundStyle(Color.aegisSkySoft)
                }
            }
        }
        .frame(minHeight: 44)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Double-tap to edit")
    }
}

#Preview("Courses · Dark") {
    CoursesView().environment(ProgramStore.preview()).environmentObject(MotionManager())
        .preferredColorScheme(.dark)
}

#Preview("Courses · Light") {
    CoursesView().environment(ProgramStore.preview()).environmentObject(MotionManager())
        .preferredColorScheme(.light)
}

#Preview("Courses · Empty, AX5") {
    CoursesView().environment(ProgramStore.preview(emptyCourses: true)).environmentObject(MotionManager())
        .dynamicTypeSize(.accessibility5)
}
