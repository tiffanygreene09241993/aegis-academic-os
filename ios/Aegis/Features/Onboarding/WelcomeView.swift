import SwiftUI

/// First launch: use the bundled Liberty data, or set up a different program.
struct WelcomeView: View {
    @Environment(ProgramStore.self) private var store
    @State private var showSetup = false

    var body: some View {
        ZStack {
            AegisBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    Spacer(minLength: Spacing.xl)
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Color.aegisAccent)
                        .shadow(color: .aegisGlow, radius: 16)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: Spacing.s) {
                        Text("Aegis")
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color.aegisText)
                        Text("Count down to commencement, see exactly what's left, and keep your honors in one place.")
                            .font(.body)
                            .foregroundStyle(Color.aegisTextSecondary)
                    }
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        FeatureRow(symbol: "hourglass", text: "Live countdown and credit progress")
                        FeatureRow(symbol: "checklist", text: "Degree audit by requirement")
                        FeatureRow(symbol: "rosette", text: "GPA, Latin honors and societies")
                        FeatureRow(symbol: "lock.shield", text: "Stays on this iPhone. No account needed.")
                    }
                    .glassCard()
                }
                .padding(Spacing.m)
            }
            .safeAreaInset(edge: .bottom) {
                GlassEffectContainer(spacing: Spacing.s) {
                    VStack(spacing: Spacing.s) {
                        Button {
                            store.useBundledDefault()
                        } label: {
                            VStack(spacing: 2) {
                                Text("Use my Liberty data").font(.headline)
                                Text("Liberty University · B.S. Criminal Justice").font(.caption)
                            }
                            .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.glassProminent)
                        .controlSize(.large)

                        Button {
                            showSetup = true
                        } label: {
                            Text("Set up my program").font(.headline)
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.glass)
                        .controlSize(.large)
                    }
                }
                .padding(Spacing.m)
            }
        }
        .sheet(isPresented: $showSetup) {
            ProgramSetupView()
        }
    }
}

private struct FeatureRow: View {
    let symbol: String
    let text: String
    var body: some View {
        Label {
            Text(text).foregroundStyle(Color.aegisText)
        } icon: {
            Image(systemName: symbol).foregroundStyle(Color.aegisAccent)
        }
        .font(.body)
    }
}

/// Simple editable setup for any student. Everything can be refined later in Settings.
struct ProgramSetupView: View {
    @Environment(ProgramStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var institution = ""
    @State private var degree = ""
    @State private var requiredText = "120"
    @State private var earnedText = "0"
    @State private var gpaText = ""
    @State private var commencement = Calendar.current.date(byAdding: .month, value: 9, to: .now) ?? .now
    @FocusState private var focus: Field?

    enum Field: Hashable { case name, institution, degree, required, earned, gpa }

    private var required: Int? { Int(requiredText) }
    private var earned: Int? { Int(earnedText) }
    private var gpa: Double? { gpaText.isEmpty ? 0 : Double(gpaText.replacingOccurrences(of: ",", with: ".")) }

    private var requiredError: String? {
        guard let r = required, (1...400).contains(r) else { return "Enter total credits required, like 120." }
        return nil
    }
    private var earnedError: String? {
        guard let e = earned, e >= 0 else { return "Enter credits earned so far (0 or more)." }
        if let r = required, e > r { return "Earned credits can't be more than required." }
        return nil
    }
    private var gpaError: String? {
        guard let g = gpa, (0...4.0).contains(g) else { return "Enter a GPA between 0.00 and 4.00, or leave blank." }
        return nil
    }
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !degree.trimmingCharacters(in: .whitespaces).isEmpty &&
        requiredError == nil && earnedError == nil && gpaError == nil
    }
    private var isDirty: Bool { !name.isEmpty || !institution.isEmpty || !degree.isEmpty }
    @State private var confirmDiscard = false

    var body: some View {
        NavigationStack {
            Form {
                Section("You") {
                    TextField("Your name", text: $name)
                        .textContentType(.name)
                        .focused($focus, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focus = .institution }
                    TextField("School or university", text: $institution)
                        .textContentType(.organizationName)
                        .focused($focus, equals: .institution)
                        .submitLabel(.next)
                        .onSubmit { focus = .degree }
                }
                Section("Program") {
                    TextField("Degree, e.g. B.A. Psychology", text: $degree)
                        .focused($focus, equals: .degree)
                        .submitLabel(.next)
                        .onSubmit { focus = .required }
                    ValidatedField("Credits required", text: $requiredText, error: requiredError, keyboard: .numberPad)
                        .focused($focus, equals: .required)
                    ValidatedField("Credits earned so far", text: $earnedText, error: earnedError, keyboard: .numberPad)
                        .focused($focus, equals: .earned)
                    ValidatedField("Cumulative GPA (optional)", text: $gpaText, error: gpaError, keyboard: .decimalPad)
                        .focused($focus, equals: .gpa)
                }
                Section {
                    DatePicker("Commencement", selection: $commencement, displayedComponents: [.date, .hourAndMinute])
                } footer: {
                    Text("You can add courses, requirements and honors after setup.")
                }
            }
            .navigationTitle("Set Up Program")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { if isDirty { confirmDiscard = true } else { dismiss() } }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        store.startCustom(.blank(name: name, institution: institution, degree: degree,
                                                 requiredCredits: required ?? 120, earnedCredits: earned ?? 0,
                                                 gpa: gpa ?? 0, commencement: commencement))
                        dismiss()
                    }
                    .disabled(!isValid)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focus = nil }
                }
            }
            .interactiveDismissDisabled(isDirty)
            .confirmationDialog("Discard this setup?", isPresented: $confirmDiscard, titleVisibility: .visible) {
                Button("Discard", role: .destructive) { dismiss() }
                Button("Keep Editing", role: .cancel) {}
            }
        }
    }
}

/// Text field with an inline error message underneath (shown only once the user has typed).
struct ValidatedField: View {
    let title: String
    @Binding var text: String
    let error: String?
    var keyboard: UIKeyboardType = .default
    @State private var touched = false

    init(_ title: String, text: Binding<String>, error: String?, keyboard: UIKeyboardType = .default) {
        self.title = title
        self._text = text
        self.error = error
        self.keyboard = keyboard
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            LabeledContent(title) {
                TextField(title, text: $text)
                    .keyboardType(keyboard)
                    .multilineTextAlignment(.trailing)
                    .labelsHidden()
                    .onChange(of: text) { touched = true }
            }
            if touched, let error {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(Color.libertyText)
                    .accessibilityLabel("Error: \(error)")
            }
        }
    }
}

#Preview("Welcome · Dark") {
    WelcomeView().environment(ProgramStore.preview(.onboarding)).environmentObject(MotionManager())
        .preferredColorScheme(.dark)
}

#Preview("Welcome · Light, XXXL") {
    WelcomeView().environment(ProgramStore.preview(.onboarding)).environmentObject(MotionManager())
        .preferredColorScheme(.light)
        .dynamicTypeSize(.accessibility3)
}

#Preview("Setup") {
    ProgramSetupView().environment(ProgramStore.preview(.onboarding))
}
