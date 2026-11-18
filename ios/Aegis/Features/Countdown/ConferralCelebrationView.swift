import SwiftUI

/// Full-screen "Congratulations" moment: the tassel turns right → left, the cap is tossed,
/// two glasses clink with a sparkle, confetti falls, and the degree is conferred.
/// With Reduce Motion on, the final state is shown at once (no movement, no confetti).
struct ConferralCelebrationView: View {
    let program: Program

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("celebrationSound") private var soundOn = true

    enum Stage: Int, Comparable {
        case verifying, tasselTurned, capTossed, clinked, conferred
        static func < (a: Stage, b: Stage) -> Bool { a.rawValue < b.rawValue }
        var status: String {
            switch self {
            case .verifying: return "Academic distinctions verified"
            case .tasselTurned: return "Conferring degree"
            case .capTossed: return "Requirements satisfied"
            case .clinked, .conferred: return "Degree conferred"
            }
        }
    }

    @State private var stage: Stage = .verifying
    @State private var tasselSide: CGFloat = 1
    @State private var capLift: CGFloat = 0
    @State private var capSpin: Double = 0
    @State private var glassesTogether = false
    @State private var sparkle = false
    @State private var credits = 0
    @State private var confettiStart: Date?
    @State private var tasselTick = 0
    @State private var successTick = 0
    @State private var sequence: Task<Void, Never>?
    @State private var sound = CelebrationSound()

    private var firstName: String {
        program.student.name.split(separator: " ").first.map(String.init) ?? program.student.name
    }

    var body: some View {
        ZStack {
            AegisBackground()
            if let confettiStart, !reduceMotion {
                ConfettiView(start: confettiStart).ignoresSafeArea()
            }
            ScrollView {
                VStack(spacing: Spacing.l) {
                    header
                    scene
                        .frame(height: 300)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(stage >= .clinked
                            ? "Graduation cap with the tassel turned to the left, and two glasses raised in a toast"
                            : "Graduation cap with tassel")
                    creditCounter
                    seal
                }
                .padding(Spacing.m)
                .frame(maxWidth: .infinity)
            }
            .safeAreaInset(edge: .bottom) { actions }
        }
        .environment(\.colorScheme, .dark) // the celebration is always in the hero (dark) palette
        .sensoryFeedback(.impact(weight: .light), trigger: tasselTick)
        .sensoryFeedback(.success, trigger: successTick)
        .onAppear(perform: run)
        .onDisappear {
            sequence?.cancel()
            sound.stop()
        }
    }

    // MARK: Pieces

    private var header: some View {
        VStack(spacing: Spacing.s) {
            Text("Congratulations, \(firstName)")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.aegisText)
            Text(stage.status.uppercased())
                .font(.footnote.weight(.semibold))
                .tracking(1.5)
                .foregroundStyle(Color.aegisAccent)
                .contentTransition(.opacity)
                .accessibilityLabel(stage.status)
        }
        .padding(.top, Spacing.l)
    }

    private var scene: some View {
        GeometryReader { geo in
            let capWidth = min(geo.size.width * 0.62, 240)
            ZStack {
                // Cap + tassel
                ZStack {
                    MortarboardShape()
                        .fill(LinearGradient(colors: [Color(red: 0.06, green: 0.15, blue: 0.29), Color(red: 0.02, green: 0.07, blue: 0.16)],
                                             startPoint: .top, endPoint: .bottom))
                    MortarboardShape()
                        .stroke(Color.aegisAccent.opacity(0.7), lineWidth: 1.5)
                    TasselShape(side: tasselSide)
                        .stroke(Color(red: 0.96, green: 0.91, blue: 0.74), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    TasselFringeShape(side: tasselSide)
                        .fill(Color(red: 0.96, green: 0.91, blue: 0.74))
                    Circle()
                        .fill(Color(red: 0.96, green: 0.91, blue: 0.74))
                        .frame(width: 8, height: 8)
                        .position(x: capWidth / 2, y: capWidth * 0.62 * 0.28)
                }
                .frame(width: capWidth, height: capWidth * 0.62)
                .shadow(color: .aegisGlow, radius: 18)
                .rotationEffect(.degrees(capSpin))
                .offset(y: -geo.size.height * 0.22 - capLift * geo.size.height * 0.55)
                .tiltEffect(depth: 8, highlight: false)

                // Glasses
                HStack(spacing: glassesTogether ? -14 : 48) {
                    WineGlassView()
                        .frame(height: 110)
                        .rotationEffect(.degrees(glassesTogether ? 16 : -4), anchor: .bottom)
                    WineGlassView()
                        .frame(height: 110)
                        .rotationEffect(.degrees(glassesTogether ? -16 : 4), anchor: .bottom)
                }
                .offset(y: geo.size.height * 0.28)
                .opacity(stage >= .capTossed ? 1 : 0)

                Image(systemName: "sparkle")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color.aegisAccent)
                    .shadow(color: .aegisGlow, radius: 10)
                    .scaleEffect(sparkle ? 1 : 0.1)
                    .opacity(sparkle ? 1 : 0)
                    .offset(y: geo.size.height * 0.28 - 62)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private var creditCounter: some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
            Text("\(credits)")
                .font(.system(.largeTitle, design: .rounded, weight: .bold).monospacedDigit())
                .foregroundStyle(Color.aegisAccent)
                .contentTransition(.numericText())
            Text("/ \(program.requiredCredits) credits")
                .font(.headline)
                .foregroundStyle(Color.aegisTextSecondary)
        }
        .accessibilityElement(children: .combine)
    }

    private var seal: some View {
        VStack(spacing: Spacing.xs) {
            Text("Degree Conferred")
                .font(.title2.bold())
                .foregroundStyle(.white)
            if let honor = program.projectedLatinHonor {
                Text(honor.name.uppercased())
                    .font(.subheadline.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(.white)
            }
            Text("Cumulative GPA \(program.cumulativeGPA, format: .number.precision(.fractionLength(2)))")
                .font(.footnote.monospacedDigit())
                .foregroundStyle(.white.opacity(0.9))
            Text("\(program.student.institution) · \(program.degree)")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity)
        // Liberty red is reserved for this moment.
        .glassEffect(.regular.tint(Color.liberty.opacity(0.85)), in: .rect(cornerRadius: Radius.card))
        .opacity(stage >= .conferred ? 1 : 0.25)
        .scaleEffect(stage >= .conferred || reduceMotion ? 1 : 0.96)
        .accessibilityElement(children: .combine)
        .accessibilityHidden(stage < .conferred)
    }

    private var actions: some View {
        GlassEffectContainer(spacing: Spacing.s) {
            HStack(spacing: Spacing.s) {
                Button {
                    soundOn.toggle()
                } label: {
                    Image(systemName: soundOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.glass)
                .accessibilityLabel(soundOn ? "Sound on" : "Sound off")
                .accessibilityHint("Toggles the celebration sound")

                Button {
                    run()
                } label: {
                    Text("Replay").frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.glass)

                Button {
                    dismiss()
                } label: {
                    Text("Done").bold().frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.glassProminent)
            }
        }
        .padding(Spacing.m)
    }

    // MARK: Sequence

    private func run() {
        sequence?.cancel()
        let startCredits = min(program.requiredCredits, Int(program.appliedCredits))

        if reduceMotion {
            // Static version: final state, one haptic, optional sound.
            stage = .conferred
            tasselSide = -1
            capLift = 0
            capSpin = 0
            glassesTogether = true
            sparkle = true
            credits = program.requiredCredits
            confettiStart = nil
            successTick += 1
            if soundOn { sound.play() }
            announce()
            return
        }

        stage = .verifying
        tasselSide = 1
        capLift = 0
        capSpin = 0
        glassesTogether = false
        sparkle = false
        credits = startCredits
        confettiStart = nil

        sequence = Task { @MainActor in
            func pause(_ s: Double) async -> Bool {
                try? await Task.sleep(for: .seconds(s))
                return !Task.isCancelled
            }
            guard await pause(0.7) else { return }

            // 1. Turning of the tassel (right → left)
            withAnimation(.spring(duration: 0.6, bounce: 0.25)) {
                tasselSide = -1
                stage = .tasselTurned
            }
            tasselTick += 1

            // Credits resolve to the full requirement in steps.
            let steps = max(1, (program.requiredCredits - startCredits + 2) / 3)
            for i in 1...steps {
                guard await pause(0.12) else { return }
                withAnimation(.snappy(duration: 0.2)) {
                    credits = min(program.requiredCredits, startCredits + i * 3)
                }
            }
            guard await pause(0.4) else { return }

            // 2. Cap toss
            withAnimation(.easeOut(duration: 0.45)) {
                capLift = 1
                capSpin = 200
                stage = .capTossed
            }
            guard await pause(0.45) else { return }
            withAnimation(.easeIn(duration: 0.45)) {
                capLift = 0
                capSpin = 360
            }
            guard await pause(0.5) else { return }
            capSpin = 0

            // 3. Glasses clink + sparkle + confetti
            withAnimation(.spring(duration: 0.35, bounce: 0.35)) {
                glassesTogether = true
                stage = .clinked
            }
            guard await pause(0.3) else { return }
            withAnimation(.spring(duration: 0.3, bounce: 0.5)) { sparkle = true }
            confettiStart = .now
            successTick += 1
            if soundOn { sound.play() }

            guard await pause(0.4) else { return }
            withAnimation(.easeOut(duration: 0.3)) { stage = .conferred }
            announce()
        }
    }

    private func announce() {
        AccessibilityNotification.Announcement("Degree conferred. Congratulations, \(firstName)!").post()
    }
}

#Preview("Celebration") {
    ConferralCelebrationView(program: ProgramStore.preview().program!)
        .environmentObject(MotionManager())
}

#Preview("Celebration · AX3 type") {
    ConferralCelebrationView(program: ProgramStore.preview().program!)
        .environmentObject(MotionManager())
        .dynamicTypeSize(.accessibility3)
}
