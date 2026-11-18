import SwiftUI
import UserNotifications

/// Settings sheet. Edits a draft copy; Done saves, Cancel discards.
struct SettingsView: View {
    @Environment(ProgramStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @AppStorage("appearance") private var appearance: AppearancePreference = .system
    @AppStorage("remindersEnabled") private var remindersEnabled = false

    @State private var draft: Program?
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var showPrePrompt = false
    @State private var confirmDiscard = false
    @State private var confirmReset = false
    @State private var confirmStartOver = false
    @State private var addingHonor = false
    @State private var addingCategory = false

    private var isDirty: Bool { draft != nil && draft != store.program }

    var body: some View {
        NavigationStack {
            Group {
                if draft != nil {
                    form
                } else {
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { if isDirty { confirmDiscard = true } else { dismiss() } }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: saveAndClose).disabled(!isDraftValid)
                }
            }
            .interactiveDismissDisabled(isDirty)
            .confirmationDialog("Discard your changes?", isPresented: $confirmDiscard, titleVisibility: .visible) {
                Button("Discard Changes", role: .destructive) { dismiss() }
                Button("Keep Editing", role: .cancel) {}
            }
            .sheet(isPresented: $showPrePrompt) {
                NotificationPrePromptView { allowed in
                    remindersEnabled = allowed
                    Task { await refreshNotificationStatus() }
                    if allowed, let p = draft { Task { await NotificationScheduler.scheduleReminders(for: p) } }
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $addingHonor) {
                HonorEditorView { draft?.honors.append($0) }
            }
            .sheet(isPresented: $addingCategory) {
                CategoryEditorView { draft?.categories.append($0) }
            }
            .task {
                if draft == nil { draft = store.program }
                await refreshNotificationStatus()
            }
        }
    }

    private var isDraftValid: Bool {
        guard let d = draft else { return false }
        return d.requiredCredits > 0 && (0...d.gpaScale).contains(d.cumulativeGPA) && d.unitemizedEarnedCredits >= 0
    }

    @ViewBuilder
    private var form: some View {
        let binding = Binding<Program>(get: { draft ?? store.program! }, set: { draft = $0 })
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $appearance) {
                    ForEach(AppearancePreference.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
                .accessibilityLabel("Theme")
            }

            Section("Profile") {
                TextField("Name", text: binding.student.name).textContentType(.name)
                TextField("Institution", text: binding.student.institution).textContentType(.organizationName)
                TextField("School or college", text: Binding(
                    get: { binding.wrappedValue.student.school ?? "" },
                    set: { binding.wrappedValue.student.school = $0.isEmpty ? nil : $0 }))
            }

            Section {
                TextField("Degree", text: binding.degree)
                TextField("Cognate / concentration", text: optionalText(binding.cognate))
                TextField("Minor", text: optionalText(binding.minor))
                Stepper("Required credits: \(binding.wrappedValue.requiredCredits)",
                        value: binding.requiredCredits, in: 1...400)
                Stepper("Earned, not itemized: \(binding.wrappedValue.unitemizedEarnedCredits)",
                        value: binding.unitemizedEarnedCredits, in: 0...400)
                Stepper("Earned, not applied: \(binding.wrappedValue.nonApplicableCredits ?? 0)",
                        value: Binding(get: { binding.wrappedValue.nonApplicableCredits ?? 0 },
                                       set: { binding.wrappedValue.nonApplicableCredits = $0 == 0 ? nil : $0 }),
                        in: 0...400)
                LabeledContent("Cumulative GPA") {
                    TextField("GPA", value: binding.cumulativeGPA, format: .number.precision(.fractionLength(2)))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                if !(0...binding.wrappedValue.gpaScale).contains(binding.wrappedValue.cumulativeGPA) {
                    Text("GPA must be between 0.00 and \(binding.wrappedValue.gpaScale, format: .number.precision(.fractionLength(2))).")
                        .font(.footnote).foregroundStyle(Color.libertyText)
                }
            } header: {
                Text("Program")
            } footer: {
                Text("“Earned, not itemized” covers credits you don't want to list course by course. “Earned, not applied” is earned credit your degree audit doesn't count toward requirements, such as extra transfer electives.")
            }

            Section("Requirements") {
                ForEach(binding.categories) { $category in
                    HStack {
                        Label(category.name, systemImage: category.symbol)
                        Spacer()
                        Text(category.requiredCredits.map { "\($0) cr" } ?? "No target")
                            .foregroundStyle(Color.aegisTextSecondary)
                    }
                }
                .onDelete { draft?.categories.remove(atOffsets: $0) }
                Button("Add Requirement") { addingCategory = true }
            }

            Section("Honor societies") {
                ForEach(binding.wrappedValue.honors) { honor in
                    VStack(alignment: .leading) {
                        Text(honor.name)
                        if let chapter = honor.chapter {
                            Text(chapter).font(.footnote).foregroundStyle(Color.aegisTextSecondary)
                        }
                    }
                }
                .onDelete { draft?.honors.remove(atOffsets: $0) }
                Button("Add Society") { addingHonor = true }
            }

            Section {
                DatePicker("Date & time", selection: binding.commencement, displayedComponents: [.date, .hourAndMinute])
                    .environment(\.timeZone, binding.wrappedValue.commencementTimeZone)
                LabeledContent("Time zone", value: binding.wrappedValue.commencementTimeZoneID)
            } header: {
                Text("Commencement")
            }

            remindersSection

            Section {
                Button("Reset to My Liberty Data", role: .destructive) { confirmReset = true }
                Button("Start Over", role: .destructive) { confirmStartOver = true }
            } header: {
                Text("Data")
            } footer: {
                Text("Your data is stored only on this iPhone. There is no account or cloud sync.")
            }
            .confirmationDialog("Replace everything with the built-in Liberty data?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Reset", role: .destructive) {
                    store.resetAll()
                    store.useBundledDefault()
                    dismiss()
                }
            }
            .confirmationDialog("Delete your data and return to setup?", isPresented: $confirmStartOver, titleVisibility: .visible) {
                Button("Delete and Start Over", role: .destructive) {
                    Task { await NotificationScheduler.cancelReminders() }
                    remindersEnabled = false
                    store.resetAll()
                    dismiss()
                }
            }

            Section("About") {
                if let note = binding.wrappedValue.dataNote {
                    Text(note).font(.footnote).foregroundStyle(Color.aegisTextSecondary)
                }
                LabeledContent("Version", value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")
            }
        }
    }

    @ViewBuilder
    private var remindersSection: some View {
        Section {
            Toggle("Commencement reminders", isOn: Binding(
                get: { remindersEnabled && notificationStatus != .denied },
                set: { on in handleReminderToggle(on) }))
            if notificationStatus == .denied {
                Text("Notifications are turned off for Aegis in iOS Settings.")
                    .font(.footnote).foregroundStyle(Color.aegisTextSecondary)
                Button("Open iOS Settings") {
                    if let url = URL(string: UIApplication.openNotificationSettingsURLString) { openURL(url) }
                }
            }
        } header: {
            Text("Reminders")
        } footer: {
            Text("A heads-up 100, 30, 7 and 1 day before commencement at 9 AM. Scheduled on this iPhone only.")
        }
    }

    private func handleReminderToggle(_ on: Bool) {
        if !on {
            remindersEnabled = false
            Task { await NotificationScheduler.cancelReminders() }
            return
        }
        switch notificationStatus {
        case .notDetermined:
            showPrePrompt = true      // explain first, then ask iOS
        case .denied:
            break
        default:
            remindersEnabled = true
            if let p = draft { Task { await NotificationScheduler.scheduleReminders(for: p) } }
        }
    }

    private func refreshNotificationStatus() async {
        notificationStatus = await NotificationScheduler.authorizationStatus()
    }

    private func saveAndClose() {
        guard let draft else { return }
        if draft != store.program { store.replaceProgram(draft) }
        if remindersEnabled { Task { await NotificationScheduler.scheduleReminders(for: draft) } }
        dismiss()
    }

    private func optionalText(_ b: Binding<String?>) -> Binding<String> {
        Binding(get: { b.wrappedValue ?? "" }, set: { b.wrappedValue = $0.isEmpty ? nil : $0 })
    }
}

/// Explains reminders before the system permission alert appears.
struct NotificationPrePromptView: View {
    var completion: (Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var asking = false

    var body: some View {
        VStack(spacing: Spacing.l) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.aegisAccent)
                .accessibilityHidden(true)
            Text("Get commencement reminders?")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text("Aegis can send a few reminders as the big day gets close: 100, 30, 7 and 1 day before. Nothing else, and nothing leaves your iPhone. iOS will ask you to confirm next.")
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.aegisTextSecondary)
            Spacer(minLength: 0)
            GlassEffectContainer(spacing: Spacing.s) {
                VStack(spacing: Spacing.s) {
                    Button {
                        asking = true
                        Task {
                            let allowed = await NotificationScheduler.requestAuthorization()
                            completion(allowed)
                            dismiss()
                        }
                    } label: {
                        Text("Continue").font(.headline).frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(asking)

                    Button {
                        completion(false)
                        dismiss()
                    } label: {
                        Text("Not Now").frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.glass)
                }
            }
        }
        .padding(Spacing.l)
    }
}

/// Minimal add-society form.
struct HonorEditorView: View {
    var onSave: (Honor) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var chapter = ""
    @State private var status = "Inducted"
    @State private var inducted = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Society name", text: $name)
                TextField("Chapter (optional)", text: $chapter)
                TextField("Status", text: $status)
                TextField("Inducted, e.g. Fall 2026 (optional)", text: $inducted)
                if name.trimmingCharacters(in: .whitespaces).isEmpty {
                    Text("Enter the society's name to save.").font(.footnote).foregroundStyle(Color.aegisTextSecondary)
                }
            }
            .navigationTitle("Add Society")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(Honor(id: UUID().uuidString, name: name.trimmingCharacters(in: .whitespaces),
                                     chapter: chapter.isEmpty ? nil : chapter, discipline: nil,
                                     status: status.isEmpty ? "Member" : status,
                                     inducted: inducted.isEmpty ? nil : inducted,
                                     requirement: nil, summary: nil, regaliaCords: nil))
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

/// Minimal add-requirement form.
struct CategoryEditorView: View {
    var onSave: (RequirementCategory) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var creditsText = ""

    private var creditsError: String? {
        guard !creditsText.isEmpty else { return nil }
        guard let c = Int(creditsText), (1...200).contains(c) else { return "Enter 1–200, or leave blank." }
        return nil
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Requirement name, e.g. Major Core", text: $name)
                TextField("Credit target (optional)", text: $creditsText).keyboardType(.numberPad)
                if let creditsError {
                    Text(creditsError).font(.footnote).foregroundStyle(Color.libertyText)
                }
            }
            .navigationTitle("Add Requirement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(RequirementCategory(id: UUID().uuidString, name: name.trimmingCharacters(in: .whitespaces),
                                                   summary: nil, requiredCredits: Int(creditsText), symbol: "list.bullet.rectangle"))
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || creditsError != nil)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview("Settings · Dark") {
    SettingsView().environment(ProgramStore.preview()).preferredColorScheme(.dark)
}

#Preview("Settings · Light, AX3") {
    SettingsView().environment(ProgramStore.preview())
        .preferredColorScheme(.light)
        .dynamicTypeSize(.accessibility3)
}

#Preview("Notification pre-prompt") {
    NotificationPrePromptView { _ in }
}
