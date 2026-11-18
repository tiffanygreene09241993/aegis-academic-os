import AVFoundation

/// A short synthesized fanfare (C–E–G–C), like the web app's audio celebration.
/// Uses the ambient category so it respects the silent switch and mixes with other audio.
@MainActor
final class CelebrationSound {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var prepared = false

    func play() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
            if !prepared {
                engine.attach(player)
                engine.connect(player, to: engine.mainMixerNode, format: format)
                prepared = true
            }
            if !engine.isRunning { try engine.start() }
            guard let buffer = Self.fanfare(format: format) else { return }
            player.scheduleBuffer(buffer, at: nil, options: .interrupts)
            player.play()
        } catch {
            // Sound is optional; the visual + haptic celebration still runs.
        }
    }

    func stop() {
        player.stop()
        engine.stop()
    }

    private static func fanfare(format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let notes: [(freq: Double, length: Double)] = [(523.25, 0.14), (659.25, 0.14), (783.99, 0.14), (1046.5, 0.55)]
        let rate = format.sampleRate
        let total = AVAudioFrameCount(notes.reduce(0) { $0 + $1.length } * rate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: total),
              let channel = buffer.floatChannelData?[0] else { return nil }
        var frame = 0
        for note in notes {
            let count = Int(note.length * rate)
            for i in 0..<count {
                let t = Double(i) / rate
                let envelope = min(1, t / 0.01) * exp(-3.2 * t / note.length)
                let sample = sin(2 * .pi * note.freq * t) * 0.6 + sin(4 * .pi * note.freq * t) * 0.15
                channel[frame + i] = Float(sample * envelope * 0.35)
            }
            frame += count
        }
        buffer.frameLength = AVAudioFrameCount(frame)
        return buffer
    }
}
