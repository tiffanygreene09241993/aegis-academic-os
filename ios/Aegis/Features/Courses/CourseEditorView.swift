import SwiftUI

/// Add / edit a course in a sheet. Save stays disabled until the inline validation passes;
/// closing with unsaved changes asks for confirmation.
struct CourseEditorView: View {
    let existing: Course?
    var defaultCategoryID: String?

    @Environment(ProgramStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var code = ""
    @State private var title = ""
    @State private var creditsText = "3"
    @State private var status: CourseStatus = .planned
    @State private var term = ""
    @State private var grade = ""
    @State private var categoryID = ""
    @State private var source: CourseSource = .institutional
    @State private var loaded = false
    @State private var showErrors = false
    @State private var confirmDiscard = false
    @State private var saveTick = 0
    @FocusState private var focus: Field?

    enum Field: Hashable { case code, title, credits, term, grade }

    private var errors: CourseValidation.Errors {
        CourseValidation.validate(code: code, title: title, creditsText: creditsText)
    }

    private var isDirty: Bool {
        guard let e = existing else { return !code.isEmpty || !title.isEmpty || !term.isEmpty }
        return e.code != code || e.title != title || CreditFormat.string(e.credits) != creditsText || e.status != status
            || e.term != term || (e.grade ?? "") != grade || e.categoryID != categoryID
            || (e.source ?? .institutional) != source
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    field("Course code", text: $code, error: errors.code, focus: .code, next: .title,
                          capitalization: .characters, autocorrect: false)
                    field("Title", text: $title, error: errors.title, focus: .title, next: .credits,
                          capitalization: .words)
                    field("Credits", text: $creditsText, error: errors.credits, focus: .credits, next: .term,
                          keyboard: .decimalPad)
                    Picker("Taken at", selection: $source) {
                        Text("This school").tag(CourseSource.institutional)
                        Text("Transfer").tag(CourseSource.transfer)
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("Taken at")
                }
                Section {
                    Picker("Status", selection: $status) {
                        ForEach(CourseStatus.allCases) { Text($0.label).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("Status")
                    TextField("Term, e.g. Spring 2027 · Sub-Term B", text: $term)
                        .focused($focus, equals: .term)
                        .submitLabel(.next)
                        .onSubmit { focus = .grade }
                    TextField(status == .planned ? "Grade (after it's finished)" : "Grade, e.g. A", text: $grade)
                        .focused($focus, equals: .grade)
                        .submitLabel(.done)
                        .onSubmit { focus = nil }
                }
                if let categories = store.program?.categories, !categories.isEmpty {
                    Section("Requirement") {
                        Picker("Counts toward", selection: $categoryID) {
                            ForEach(categories) { Text($0.name).tag($0.id) }
                        }
                    }
                }
            }
            .navigationTitle(existing == nil ? "Add Course" : "Edit Course")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { if isDirty { confirmDiscard = true } else { dismiss() } }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(!errors.isEmpty)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focus = nil }
                }
            }
            .interactiveDismissDisabled(isDirty)
            .confirmationDialog("Discard your changes?", isPresented: $confirmDiscard, titleVisibility: .visible) {
                Button("Discard Changes", role: .destructive) { dismiss() }
                Button("Keep Editing", role: .cancel) {}
            }
            .sensoryFeedback(.success, trigger: saveTick)
            .onAppear(perform: load)
        }
    }

    private func field(_ label: String, text: Binding<String>, error: String?, focus f: Field, next: Field,
                       keyboard: UIKeyboardType = .default,
                       capitalization: TextInputAutocapitalization = .sentences,
                       autocorrect: Bool = true) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            TextField(label, text: text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(capitalization)
                .autocorrectionDisabled(!autocorrect)
                .focused($focus, equals: f)
                .submitLabel(.next)
                .onSubmit { focus = next }
                .onChange(of: text.wrappedValue) { showErrors = true }
            if showErrors, let error {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(Color.libertyText)
                    .accessibilityLabel("Error: \(error)")
            }
        }
    }

    private func load() {
        guard !loaded else { return }
        loaded = true
        if let e = existing {
            code = e.code; title = e.title; creditsText = CreditFormat.string(e.credits); status = e.status
            term = e.term; grade = e.grade ?? ""; categoryID = e.categoryID; source = e.source ?? .institutional
        } else {
            categoryID = defaultCategoryID ?? store.program?.categories.first?.id ?? ""
            focus = .code
        }
    }

    private func save() {
        guard errors.isEmpty, let credits = CourseValidation.parseCredits(creditsText) else { return }
        let trimmedGrade = grade.trimmingCharacters(in: .whitespaces)
        let course = Course(id: existing?.id ?? UUID(),
                            code: code.trimmingCharacters(in: .whitespaces).uppercased(),
                            title: title.trimmingCharacters(in: .whitespaces),
                            credits: credits, status: status,
                            term: term.trimmingCharacters(in: .whitespaces),
                            grade: trimmedGrade.isEmpty ? nil : trimmedGrade,
                            categoryID: categoryID,
                            source: source)
        store.upsert(course)
        saveTick += 1
        dismiss()
    }
}

#Preview("Add course") {
    CourseEditorView(existing: nil).environment(ProgramStore.preview())
}

#Preview("Edit course · Dark, AX3") {
    let store = ProgramStore.preview()
    return CourseEditorView(existing: store.program?.courses.first)
        .environment(store)
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility3)
}
