import SwiftUI

/// Switches between loading, first-launch choice, error and the main tabs.
struct RootView: View {
    @Environment(ProgramStore.self) private var store
    @EnvironmentObject private var motion: MotionManager
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            switch store.phase {
            case .loading:
                ZStack { AegisBackground(); LoadingSkeleton() }
            case .onboarding:
                WelcomeView()
            case .failed(let message):
                ZStack {
                    AegisBackground()
                    ErrorStateView(message: message) { Task { await store.load() } }
                }
            case .ready:
                MainTabView()
            }
        }
        .task { if store.phase == .loading { await store.load() } }
        .onChange(of: scenePhase, initial: true) { _, phase in
            motion.update(scenePhase: phase, reduceMotion: reduceMotion)
        }
        .onChange(of: reduceMotion) { _, reduce in
            motion.update(scenePhase: scenePhase, reduceMotion: reduce)
        }
    }
}

enum AppTab: Hashable { case countdown, audit, courses, honors }

struct MainTabView: View {
    @State private var selection: AppTab = .countdown

    var body: some View {
        // iOS 26 renders this tab bar in Liquid Glass automatically.
        TabView(selection: $selection) {
            Tab("Countdown", systemImage: "hourglass", value: AppTab.countdown) {
                CountdownView()
            }
            Tab("Degree Audit", systemImage: "checklist", value: AppTab.audit) {
                DegreeAuditView()
            }
            Tab("Courses", systemImage: "books.vertical", value: AppTab.courses) {
                CoursesView()
            }
            Tab("Honors", systemImage: "rosette", value: AppTab.honors) {
                HonorsView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview("Tabs · Dark") {
    MainTabView()
        .environment(ProgramStore.preview())
        .environmentObject(MotionManager())
        .preferredColorScheme(.dark)
}

#Preview("Tabs · Light") {
    MainTabView()
        .environment(ProgramStore.preview())
        .environmentObject(MotionManager())
        .preferredColorScheme(.light)
}

#Preview("Loading") {
    RootView()
        .environment(ProgramStore.preview(.loading))
        .environmentObject(MotionManager())
}

#Preview("Load error") {
    RootView()
        .environment(ProgramStore.preview(.failed("Your saved data couldn't be read.")))
        .environmentObject(MotionManager())
}
