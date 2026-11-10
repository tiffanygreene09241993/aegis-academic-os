/**
 * Synthesizes an authentic graduation ceremonial chime & trumpet fanfare
 * using the Web Audio API without needing any external audio assets.
 */

let audioCtx: AudioContext | null = null;

function getAudioContext(): AudioContext {
  if (!audioCtx) {
    const AudioContextClass = window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
    audioCtx = new AudioContextClass();
  }
  if (audioCtx.state === 'suspended') {
    audioCtx.resume();
  }
  return audioCtx;
}

export function playGraduationFanfare(muted = false): void {
  if (muted) return;
  try {
    const ctx = getAudioContext();
    const now = ctx.currentTime;

    // Fanfare Notes (G4, C5, E5, G5, C6)
    const fanfareNotes = [
      { freq: 392.00, start: 0.0, dur: 0.25 }, // G4
      { freq: 523.25, start: 0.22, dur: 0.28 }, // C5
      { freq: 659.25, start: 0.46, dur: 0.28 }, // E5
      { freq: 783.99, start: 0.72, dur: 0.45 }, // G5
      { freq: 1046.50, start: 1.15, dur: 1.80 }, // C6 grand triumphant note
    ];

    fanfareNotes.forEach(({ freq, start, dur }) => {
      const startTime = now + start;

      // Primary tone
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();

      osc.type = 'triangle';
      osc.frequency.setValueAtTime(freq, startTime);

      // Warm harmonic overtone
      const oscHarmonic = ctx.createOscillator();
      const gainHarmonic = ctx.createGain();
      oscHarmonic.type = 'sine';
      oscHarmonic.frequency.setValueAtTime(freq * 2, startTime);

      // Envelope: punchy attack, stately sustain, resonant tail
      gain.gain.setValueAtTime(0.0001, startTime);
      gain.gain.exponentialRampToValueAtTime(0.35, startTime + 0.04);
      gain.gain.exponentialRampToValueAtTime(0.25, startTime + dur * 0.4);
      gain.gain.exponentialRampToValueAtTime(0.0001, startTime + dur);

      gainHarmonic.gain.setValueAtTime(0.0001, startTime);
      gainHarmonic.gain.exponentialRampToValueAtTime(0.15, startTime + 0.05);
      gainHarmonic.gain.exponentialRampToValueAtTime(0.0001, startTime + dur);

      osc.connect(gain);
      gain.connect(ctx.destination);
      oscHarmonic.connect(gainHarmonic);
      gainHarmonic.connect(ctx.destination);

      osc.start(startTime);
      osc.stop(startTime + dur + 0.1);
      oscHarmonic.start(startTime);
      oscHarmonic.stop(startTime + dur + 0.1);
    });

    // Sub chime bell resonance for degree conferral prestige
    const bellOsc = ctx.createOscillator();
    const bellGain = ctx.createGain();
    bellOsc.type = 'sine';
    bellOsc.frequency.setValueAtTime(587.33, now + 1.2); // D5 chime
    bellGain.gain.setValueAtTime(0.0001, now + 1.2);
    bellGain.gain.exponentialRampToValueAtTime(0.2, now + 1.25);
    bellGain.gain.exponentialRampToValueAtTime(0.0001, now + 3.2);

    bellOsc.connect(bellGain);
    bellGain.connect(ctx.destination);
    bellOsc.start(now + 1.2);
    bellOsc.stop(now + 3.3);

  } catch {
    // Graceful fallback if user hasn't interacted or audio is blocked
  }
}

export function playTickChime(): void {
  try {
    const ctx = getAudioContext();
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(880, ctx.currentTime);
    gain.gain.setValueAtTime(0.05, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.0001, ctx.currentTime + 0.08);
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.start();
    osc.stop(ctx.currentTime + 0.09);
  } catch {
    // Ignore audio context error
  }
}
