import SwiftUI

/// Mortarboard: a flat board seen at a slight angle on top of the skull cap.
struct MortarboardShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        // Board (rhombus)
        p.move(to: CGPoint(x: rect.minX + w * 0.5, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + h * 0.28))
        p.addLine(to: CGPoint(x: rect.minX + w * 0.5, y: rect.minY + h * 0.56))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + h * 0.28))
        p.closeSubpath()
        // Skull cap
        p.move(to: CGPoint(x: rect.minX + w * 0.22, y: rect.minY + h * 0.44))
        p.addLine(to: CGPoint(x: rect.minX + w * 0.22, y: rect.minY + h * 0.80))
        p.addQuadCurve(to: CGPoint(x: rect.minX + w * 0.78, y: rect.minY + h * 0.80),
                       control: CGPoint(x: rect.minX + w * 0.5, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX + w * 0.78, y: rect.minY + h * 0.44))
        p.addLine(to: CGPoint(x: rect.minX + w * 0.5, y: rect.minY + h * 0.56))
        p.closeSubpath()
        return p
    }
}

/// Tassel cord anchored at the board's center button. `side` goes from 1 (right) to -1 (left);
/// the cord arcs up over the board as it swings, like the turning of the tassel.
struct TasselShape: Shape {
    var side: CGFloat

    var animatableData: CGFloat {
        get { side }
        set { side = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        let button = CGPoint(x: rect.midX, y: rect.minY + h * 0.28)
        let lift = (1 - side * side) * h * 0.30
        let edge = CGPoint(x: rect.midX + side * w * 0.46, y: rect.minY + h * 0.30 - lift)
        p.move(to: button)
        p.addQuadCurve(to: edge, control: CGPoint(x: rect.midX + side * w * 0.25, y: button.y - h * 0.06 - lift))
        // Hanging strand
        let strandLength = h * 0.42 * max(0.35, abs(side))
        p.addLine(to: CGPoint(x: edge.x, y: edge.y + strandLength))
        return p
    }
}

/// The tassel's fringe at the end of the strand, positioned with the same math as `TasselShape`.
struct TasselFringeShape: Shape {
    var side: CGFloat
    var animatableData: CGFloat {
        get { side }
        set { side = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let lift = (1 - side * side) * h * 0.30
        let x = rect.midX + side * w * 0.46
        let top = rect.minY + h * 0.30 - lift + h * 0.42 * max(0.35, abs(side))
        var p = Path()
        p.move(to: CGPoint(x: x, y: top))
        p.addLine(to: CGPoint(x: x + w * 0.035, y: top + h * 0.16))
        p.addLine(to: CGPoint(x: x - w * 0.035, y: top + h * 0.16))
        p.closeSubpath()
        return p
    }
}

/// Wine / champagne glass outline: bowl, stem and foot.
struct WineGlassShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        let bowlBottom = rect.minY + h * 0.52
        p.move(to: CGPoint(x: rect.minX + w * 0.12, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - w * 0.12, y: rect.minY))
        p.addCurve(to: CGPoint(x: rect.midX + w * 0.04, y: bowlBottom),
                   control1: CGPoint(x: rect.maxX, y: rect.minY + h * 0.30),
                   control2: CGPoint(x: rect.midX + w * 0.30, y: bowlBottom))
        p.addLine(to: CGPoint(x: rect.midX + w * 0.04, y: rect.maxY - h * 0.05))
        p.addLine(to: CGPoint(x: rect.midX + w * 0.30, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.midX - w * 0.30, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.midX - w * 0.04, y: rect.maxY - h * 0.05))
        p.addLine(to: CGPoint(x: rect.midX - w * 0.04, y: bowlBottom))
        p.addCurve(to: CGPoint(x: rect.minX + w * 0.12, y: rect.minY),
                   control1: CGPoint(x: rect.midX - w * 0.30, y: bowlBottom),
                   control2: CGPoint(x: rect.minX, y: rect.minY + h * 0.30))
        p.closeSubpath()
        return p
    }
}

/// Liquid inside the bowl (lower part of the bowl only).
struct WineLiquidShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        let surface = rect.minY + h * 0.18
        let bowlBottom = rect.minY + h * 0.50
        p.move(to: CGPoint(x: rect.minX + w * 0.10, y: surface))
        p.addLine(to: CGPoint(x: rect.maxX - w * 0.10, y: surface))
        p.addCurve(to: CGPoint(x: rect.midX, y: bowlBottom),
                   control1: CGPoint(x: rect.maxX - w * 0.06, y: rect.minY + h * 0.34),
                   control2: CGPoint(x: rect.midX + w * 0.26, y: bowlBottom))
        p.addCurve(to: CGPoint(x: rect.minX + w * 0.10, y: surface),
                   control1: CGPoint(x: rect.midX - w * 0.26, y: bowlBottom),
                   control2: CGPoint(x: rect.minX + w * 0.06, y: rect.minY + h * 0.34))
        p.closeSubpath()
        return p
    }
}

/// A single glass: translucent bowl, champagne liquid, pale outline.
struct WineGlassView: View {
    var body: some View {
        ZStack {
            WineGlassShape().fill(Color.white.opacity(0.10))
            WineLiquidShape().fill(
                LinearGradient(colors: [Color(red: 0.96, green: 0.91, blue: 0.74), Color(red: 0.78, green: 0.70, blue: 0.53)],
                               startPoint: .top, endPoint: .bottom))
            WineGlassShape().stroke(Color.aegisText.opacity(0.85), lineWidth: 2)
        }
        .aspectRatio(0.55, contentMode: .fit)
    }
}

/// Lightweight confetti drawn with Canvas. Particles are deterministic so replays look the same.
struct ConfettiView: View {
    let start: Date
    var duration: Double = 3.2
    private static let colors: [Color] = [
        Color(red: 0, green: 0.96, blue: 1),          // #00F5FF
        Color(red: 0.31, green: 0.66, blue: 0.87),    // #4EA8DE
        Color(red: 0.88, green: 0.97, blue: 1),       // #E0F7FF
        .white,
        Color(red: 0.72, green: 0.13, blue: 0.15),    // #B72025
        Color(red: 0.96, green: 0.91, blue: 0.74)     // champagne
    ]

    private struct Particle {
        let x: Double, speed: Double, drift: Double, spin: Double, size: Double, color: Int, delay: Double
    }

    private static let particles: [Particle] = {
        var seed: UInt64 = 0xAE615
        func rand() -> Double {
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            return Double(seed >> 11) / Double(1 << 53)
        }
        return (0..<90).map { _ in
            Particle(x: rand(), speed: 0.45 + rand() * 0.55, drift: rand() * 2 - 1, spin: rand() * 8 - 4,
                     size: 6 + rand() * 6, color: Int(rand() * 6) % 6, delay: rand() * 0.5)
        }
    }()

    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSince(start)
            Canvas { ctx, size in
                guard t < duration + 0.6 else { return }
                for p in Self.particles {
                    let local = t - p.delay
                    guard local > 0 else { continue }
                    let fade = max(0, 1 - max(0, local - duration * 0.7) / (duration * 0.3))
                    let y = -20 + local * p.speed * size.height * 0.55 + 0.5 * 200 * local * local * 0.25
                    let x = p.x * size.width + sin(local * 2 + p.drift * 3) * 24 * p.drift
                    var c = ctx
                    c.opacity = fade
                    c.translateBy(x: x, y: y)
                    c.rotate(by: .radians(local * p.spin))
                    c.fill(Path(CGRect(x: -p.size / 2, y: -p.size / 4, width: p.size, height: p.size / 2)),
                           with: .color(Self.colors[p.color]))
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
