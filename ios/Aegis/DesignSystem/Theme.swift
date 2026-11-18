import SwiftUI

/// Color roles live in Assets.xcassets with light + dark variants (dark is the hero look).
/// See README "Design tokens" for hex values and contrast ratios.
extension Color {
    static let aegisBackground = Color("AppBackground")
    static let aegisSurface = Color("Surface")
    static let aegisSurfaceElevated = Color("SurfaceElevated")
    static let aegisAccent = Color("AccentColor")      // electric cyan (dark) / deep cyan (light)
    static let aegisGlow = Color("AccentGlow")
    static let aegisOnAccent = Color("OnAccent")
    static let aegisSky = Color("Sky")
    static let aegisSkySoft = Color("SkySoft")
    static let aegisText = Color("TextPrimary")
    static let aegisTextSecondary = Color("TextSecondary")
    static let aegisHairline = Color("Hairline")
    static let liberty = Color("Liberty")              // fills only (white text on it = 6.5:1)
    static let libertyText = Color("LibertyText")      // red used as text
}

/// 8-pt spacing grid.
enum Spacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
}

enum Radius {
    static let card: CGFloat = 24
    static let control: CGFloat = 14
}

/// Navy backdrop with a soft cyan glow, used behind every tab.
struct AegisBackground: View {
    var body: some View {
        ZStack {
            Color.aegisBackground
            RadialGradient(colors: [Color.aegisGlow, .clear], center: .topTrailing, startRadius: 0, endRadius: 420)
            RadialGradient(colors: [Color.aegisSky.opacity(0.18), .clear], center: .bottomLeading, startRadius: 0, endRadius: 380)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

extension View {
    /// Liquid Glass card (iOS 26) with tilt highlight.
    func glassCard(tint: Color? = nil, interactive: Bool = false) -> some View {
        self
            .padding(Spacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(glass(tint: tint, interactive: interactive),
                         in: .rect(cornerRadius: Radius.card, style: .continuous))
            .tiltEffect(depth: 3, cornerRadius: Radius.card)
    }

    /// Lists sit on the shared navy backdrop instead of the default grouped gray.
    func aegisListStyle() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(AegisBackground())
    }
}

private func glass(tint: Color?, interactive: Bool) -> Glass {
    var g = Glass.regular
    if let tint { g = g.tint(tint) }
    if interactive { g = g.interactive() }
    return g
}
