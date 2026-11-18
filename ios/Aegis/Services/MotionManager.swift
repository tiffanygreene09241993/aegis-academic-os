import SwiftUI
import CoreMotion

/// Subtle device-tilt values for parallax and specular highlights on glass surfaces.
/// Paused in the background and when Reduce Motion is on (callers pass that in).
@MainActor
final class MotionManager: ObservableObject {
    /// Roll and pitch, clamped to -1...1.
    @Published private(set) var tilt: CGSize = .zero

    private let motion = CMMotionManager()
    private var isRunning = false

    func start() {
        guard !isRunning, motion.isDeviceMotionAvailable else { return }
        isRunning = true
        motion.deviceMotionUpdateInterval = 1.0 / 30.0
        motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let attitude = data?.attitude else { return }
            MainActor.assumeIsolated {
                self?.apply(attitude)
            }
        }
    }

    private func apply(_ attitude: CMAttitude) {
        let x = max(-1, min(1, attitude.roll / 0.6))
        let y = max(-1, min(1, (attitude.pitch - 0.7) / 0.6)) // 0.7 rad ≈ natural reading angle
        // Light low-pass filter so the effect feels calm.
        tilt = CGSize(width: tilt.width * 0.85 + x * 0.15,
                      height: tilt.height * 0.85 + y * 0.15)
    }

    func stop() {
        guard isRunning else { return }
        motion.stopDeviceMotionUpdates()
        isRunning = false
        tilt = .zero
    }

    /// Call from scene-phase and Reduce Motion changes.
    func update(scenePhase: ScenePhase, reduceMotion: Bool) {
        if scenePhase == .active && !reduceMotion { start() } else { stop() }
    }
}

/// Parallax + moving specular highlight. No-op when the manager is stopped (tilt is zero).
struct TiltEffect: ViewModifier {
    @EnvironmentObject private var motion: MotionManager
    var depth: CGFloat = 6
    var cornerRadius: CGFloat = 24
    var showsHighlight = true

    func body(content: Content) -> some View {
        content
            .overlay {
                if showsHighlight && motion.tilt != .zero {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.16), .clear],
                                center: UnitPoint(x: 0.5 + motion.tilt.width * 0.45,
                                                  y: 0.3 + motion.tilt.height * 0.35),
                                startRadius: 4, endRadius: 220)
                        )
                        .blendMode(.plusLighter)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .offset(x: motion.tilt.width * depth, y: motion.tilt.height * depth)
    }
}

extension View {
    func tiltEffect(depth: CGFloat = 6, cornerRadius: CGFloat = 24, highlight: Bool = true) -> some View {
        modifier(TiltEffect(depth: depth, cornerRadius: cornerRadius, showsHighlight: highlight))
    }
}
