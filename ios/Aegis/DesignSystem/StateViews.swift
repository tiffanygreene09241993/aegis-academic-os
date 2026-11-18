import SwiftUI

/// Skeleton placeholder shown while data loads.
struct LoadingSkeleton: View {
    var rows = 4
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulse = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            RoundedRectangle(cornerRadius: Radius.card).frame(height: 180)
            ForEach(0..<rows, id: \.self) { _ in
                RoundedRectangle(cornerRadius: Radius.control).frame(height: 56)
            }
        }
        .foregroundStyle(Color.aegisSurfaceElevated)
        .opacity(pulse ? 0.55 : 1)
        .padding(Spacing.m)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) { pulse = true }
        }
        .accessibilityElement()
        .accessibilityLabel("Loading")
    }
}

/// Empty state with one helpful action.
struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(message)
        } actions: {
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
            }
        }
    }
}

/// Error state that says what happened and offers Retry.
struct ErrorStateView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Something went wrong", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again", action: retry)
                .buttonStyle(.glassProminent)
                .controlSize(.large)
        }
    }
}

/// Inline banner shown on any tab when saving failed.
struct SaveErrorBanner: View {
    @Environment(ProgramStore.self) private var store

    var body: some View {
        if let message = store.saveError {
            HStack(spacing: Spacing.s) {
                Image(systemName: "exclamationmark.icloud").accessibilityHidden(true)
                Text(message).font(.footnote).frame(maxWidth: .infinity, alignment: .leading)
                Button("Retry") { store.retrySave() }
                    .font(.footnote.bold())
                    .frame(minWidth: 44, minHeight: 44)
            }
            .foregroundStyle(Color.libertyText)
            .padding(.horizontal, Spacing.m)
            .glassEffect(.regular, in: .rect(cornerRadius: Radius.control))
            .padding(.horizontal, Spacing.m)
            .accessibilityElement(children: .combine)
        }
    }
}

/// Gear button that opens Settings; shared by every tab's navigation bar.
struct SettingsToolbarItem: ToolbarContent {
    @Binding var isPresented: Bool
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button { isPresented = true } label: {
                Image(systemName: "gearshape")
            }
            .accessibilityLabel("Settings")
        }
    }
}
