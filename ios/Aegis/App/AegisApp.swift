import SwiftUI

@main
struct AegisApp: App {
    @State private var store = ProgramStore()
    @StateObject private var motion = MotionManager()
    @AppStorage("appearance") private var appearance: AppearancePreference = .system

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .environmentObject(motion)
                .preferredColorScheme(appearance.colorScheme)
                .tint(.aegisAccent)
        }
    }
}
