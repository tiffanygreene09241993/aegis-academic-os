import React, { useState, useEffect, useRef } from 'react';
import confetti from 'canvas-confetti';
import { playGraduationFanfare } from './utils/audioCelebration';

export default function App() {
  // Live Countdown State to August 20, 2027
  const [countdown, setCountdown] = useState({
    days: '284',
    hours: '14',
    minutes: '32',
    seconds: '00',
  });

  // Preview Conferral Experience Modal State
  const [showConferral, setShowConferral] = useState(false);
  const [previewCredits, setPreviewCredits] = useState(112);
  const [conferralStatus, setConferralStatus] = useState('ACADEMIC DISTINCTIONS VERIFIED');
  const [isConferred, setIsConferred] = useState(false);
  const [soundEnabled, setSoundEnabled] = useState(true);

  // Quick Telemetry Info Drawer
  const [showPipelineDetails, setShowPipelineDetails] = useState(false);

  // Timers ref for sequence cleanup
  const seqTimerRef = useRef<ReturnType<typeof setTimeout>[]>([]);

  // Safe Real-time Countdown to August 20, 2027 (Month index 7 is August)
  useEffect(() => {
    const targetDate = new Date(2027, 7, 20, 0, 0, 0).getTime();

    const updateCountdown = () => {
      const now = Date.now();
      const distance = targetDate - now;

      if (distance > 0) {
        const days = Math.floor(distance / (1000 * 60 * 60 * 24)).toString();
        const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
          .toString()
          .padStart(2, '0');
        const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60))
          .toString()
          .padStart(2, '0');
        const seconds = Math.floor((distance % (1000 * 60)) / 1000)
          .toString()
          .padStart(2, '0');

        setCountdown({ days, hours, minutes, seconds });
      } else {
        setCountdown({ days: '0', hours: '00', minutes: '00', seconds: '00' });
      }
    };

    updateCountdown();
    const interval = setInterval(updateCountdown, 1000);
    return () => clearInterval(interval);
  }, []);

  const clearSequenceTimers = () => {
    seqTimerRef.current.forEach((t) => clearTimeout(t));
    seqTimerRef.current = [];
  };

  const openConferralModal = () => {
    setShowConferral(true);
    resetConferral();
    runConferralSequence();
  };

  const closeConferralModal = () => {
    setShowConferral(false);
    clearSequenceTimers();
  };

  const resetConferral = () => {
    clearSequenceTimers();
    setPreviewCredits(112);
    setConferralStatus('ACADEMIC DISTINCTIONS VERIFIED');
    setIsConferred(false);
  };

  const triggerConfettiSafe = () => {
    try {
      const fire = typeof confetti === 'function' ? confetti : (confetti as unknown as { default: typeof confetti }).default;
      if (typeof fire === 'function') {
        fire({
          particleCount: 60,
          spread: 60,
          origin: { y: 0.6 },
          colors: ['#F4E7BD', '#C6B386', '#B72025', '#75ACD8', '#FFFFFF'],
          disableForReducedMotion: true,
        });
      }
    } catch {
      // safe fallback if canvas is disabled
    }
  };

  const runConferralSequence = () => {
    clearSequenceTimers();

    const t1 = setTimeout(() => {
      setConferralStatus('CONFERRING DEGREE');

      // Step-by-step credit resolution: 112 -> 115 -> 118 -> 121
      const t2 = setTimeout(() => {
        setPreviewCredits(115);
      }, 400);

      const t3 = setTimeout(() => {
        setPreviewCredits(118);
      }, 800);

      const t4 = setTimeout(() => {
        setPreviewCredits(121);
        setConferralStatus('REQUIREMENTS SATISFIED');
        setIsConferred(true);
        triggerConfettiSafe();
        if (soundEnabled) {
          playGraduationFanfare(false);
        }
      }, 1200);

      seqTimerRef.current.push(t2, t3, t4);
    }, 800);

    seqTimerRef.current.push(t1);
  };

  useEffect(() => {
    return () => clearSequenceTimers();
  }, []);

  return (
    <div className="h-[100dvh] overflow-hidden bg-[#0A254E] text-white flex flex-col items-center justify-between p-3 selection:bg-[#B72025] selection:text-white relative font-sans select-none">
      
      {/* Decorative ambient liquid depth glows */}
      <div 
        aria-hidden="true" 
        className="fixed top-[-10%] left-[-10%] w-[45vw] h-[45vw] max-w-[320px] max-h-[320px] rounded-full bg-[#133E7C] opacity-35 blur-[100px] pointer-events-none"
      />
      <div 
        aria-hidden="true" 
        className="fixed bottom-[-10%] right-[-10%] w-[45vw] h-[45vw] max-w-[320px] max-h-[320px] rounded-full bg-[#C6B386] opacity-15 blur-[120px] pointer-events-none"
      />

      {/* Header / Brand */}
      <header className="w-full max-w-xs sm:max-w-sm flex items-center justify-between py-1 z-20 shrink-0">
        <div className="flex items-center space-x-1.5">
          <div className="w-2.5 h-2.5 rounded-full bg-[#B72025] animate-pulse shadow-[0_0_8px_rgba(183,32,37,0.8)]" />
          <span className="text-[11px] font-bold tracking-widest text-[#75ACD8]">AEGIS ACADEMIC OS</span>
        </div>
        <span className="text-[10px] font-mono text-zinc-400">LIBERTY UNIV • BS-CJ</span>
      </header>

      {/* Main Lock Screen Container (Mobile Optimized: max-w-xs sm:max-w-sm) */}
      <main className="w-full max-w-xs sm:max-w-sm my-auto flex flex-col space-y-3 z-20 shrink-0">

        {/* 1. Countdown Lock Screen Widget */}
        <div className="glass-panel rounded-2xl p-3.5 sm:p-4 text-center relative overflow-hidden">
          {/* Decorative Background Glow */}
          <div className="absolute -top-10 -right-10 w-24 h-24 bg-[#C6B386] opacity-15 rounded-full blur-xl pointer-events-none" />

          <p className="text-[10px] font-bold tracking-[0.2em] text-[#75ACD8] mb-2 uppercase">
            Target: August 20, 2027
          </p>

          {/* Live Countdown Grid with p-2 padding and text-xl font-black */}
          <div className="grid grid-cols-4 gap-1.5 my-2">
            <div className="bg-black/35 rounded-xl p-2 border border-white/5 flex flex-col items-center justify-center">
              <span className="text-xl sm:text-2xl font-black tracking-tight font-mono tabular-nums leading-none">
                {countdown.days}
              </span>
              <p className="text-[8px] uppercase tracking-wider text-zinc-400 mt-1">Days</p>
            </div>
            <div className="bg-black/35 rounded-xl p-2 border border-white/5 flex flex-col items-center justify-center">
              <span className="text-xl sm:text-2xl font-black tracking-tight font-mono tabular-nums leading-none">
                {countdown.hours}
              </span>
              <p className="text-[8px] uppercase tracking-wider text-zinc-400 mt-1">Hours</p>
            </div>
            <div className="bg-black/35 rounded-xl p-2 border border-white/5 flex flex-col items-center justify-center">
              <span className="text-xl sm:text-2xl font-black tracking-tight font-mono tabular-nums leading-none">
                {countdown.minutes}
              </span>
              <p className="text-[8px] uppercase tracking-wider text-zinc-400 mt-1">Mins</p>
            </div>
            <div className="bg-black/35 rounded-xl p-2 border border-white/5 flex flex-col items-center justify-center">
              <span className="text-xl sm:text-2xl font-black tracking-tight text-[#C6B386] font-mono tabular-nums leading-none">
                {countdown.seconds}
              </span>
              <p className="text-[8px] uppercase tracking-wider text-zinc-400 mt-1">Secs</p>
            </div>
          </div>

          {/* Progress Telemetry */}
          <div className="mt-3 pt-2.5 border-t border-white/10 flex items-center justify-between">
            <div className="text-left">
              <p className="text-[10px] font-semibold text-zinc-300">Degree Progress</p>
              <p className="text-base font-black text-white tabular-nums leading-tight">
                94 / 121 <span className="text-[10px] font-normal text-[#75ACD8]">Credits</span>
              </p>
            </div>
            <div className="text-right">
              <span className="px-2.5 py-0.5 rounded-full bg-[#B72025]/20 border border-[#B72025]/40 text-[#B72025] text-[10px] font-bold">
                78% Complete
              </span>
            </div>
          </div>

          {/* Progress Bar */}
          <div 
            className="w-full bg-black/40 h-1.5 rounded-full overflow-hidden mt-2"
            role="progressbar" 
            aria-valuenow={78} 
            aria-valuemin={0} 
            aria-valuemax={100}
            aria-label="Degree progress: 78% complete"
          >
            <div 
              className="bg-gradient-to-r from-[#75ACD8] to-[#C6B386] h-full transition-all duration-1000 ease-out" 
              style={{ width: '78%' }} 
            />
          </div>
        </div>

        {/* 2. Spring '27 Pipeline & Honors Card (Shrunk badge: w-8 h-8 text-xs) */}
        <div 
          onClick={() => setShowPipelineDetails(!showPipelineDetails)}
          role="button"
          tabIndex={0}
          onKeyDown={(e) => { if (e.key === 'Enter' || e.key === ' ') setShowPipelineDetails(!showPipelineDetails); }}
          className="glass-panel rounded-xl p-2.5 sm:p-3 flex items-center justify-between cursor-pointer hover:border-white/20 transition-all active:scale-[0.99]"
          title="Tap to toggle Spring '27 course breakdown"
        >
          <div className="flex items-center space-x-2.5">
            <div className="w-8 h-8 rounded-lg bg-[#C6B386]/20 border border-[#C6B386]/40 flex items-center justify-center text-[#C6B386] font-bold text-xs shrink-0">
              '27
            </div>
            <div className="text-left">
              <p className="text-[11px] font-bold text-white leading-tight">Spring 2027 Pipeline</p>
              <p className="text-[10px] text-zinc-300">18 Active Credits • 9 Req. Remaining</p>
            </div>
          </div>
          <div className="text-right shrink-0">
            <span className="text-[10px] font-mono font-semibold text-[#C6B386] block leading-tight">SUMMA CUM LAUDE</span>
            <p className="text-[9px] text-zinc-400">GPA 4.00</p>
          </div>
        </div>

        {/* 3. Hero Asset Preview (Scale down to w-10 h-10 and remove min-h-[140px]) */}
        <div className="glass-panel rounded-xl p-3 text-center relative flex flex-col items-center justify-center">
          {/* Scaled down Champagne Gold Cap SVG Icon (w-10 h-10) */}
          <svg 
            className="w-10 h-10 mb-1 drop-shadow-[0_6px_10px_rgba(198,179,134,0.3)] shrink-0" 
            viewBox="0 0 100 60" 
            fill="none" 
            xmlns="http://www.w3.org/2000/svg"
            aria-hidden="true"
          >
            <path d="M50 10L90 25L50 40L10 25L50 10Z" fill="url(#goldGrad)" stroke="#F4E7BD" strokeWidth="1.5"/>
            <path d="M35 33C35 45 65 45 65 33V30H35V33Z" fill="#4C3E26"/>
            <path d="M70 28L80 45" stroke="#081F42" strokeWidth="2.5" strokeLinecap="round"/>
            <circle cx="50" cy="25" r="3" fill="#F4E7BD"/>
            <defs>
              <linearGradient id="goldGrad" x1="10" y1="10" x2="90" y2="40" gradientUnits="userSpaceOnUse">
                <stop stopColor="#F4E7BD"/>
                <stop offset="0.5" stopColor="#C6B386"/>
                <stop offset="1" stopColor="#806D43"/>
              </linearGradient>
            </defs>
          </svg>
          <p className="text-[10px] font-bold text-[#C6B386] tracking-wider uppercase leading-tight">
            Champagne-Gold Mortarboard
          </p>
          <p className="text-[9px] text-zinc-400 mt-0.5 leading-none">
            Omega Nu Lambda & Sword & Shield Honored
          </p>
        </div>

        {/* 4. Action Button: adjusted padding to py-2.5 */}
        <button 
          onClick={openConferralModal}
          className="w-full py-2.5 sm:py-3 rounded-xl bg-gradient-to-r from-[#C6B386] to-[#806D43] text-[#0A254E] font-extrabold text-xs sm:text-sm tracking-wider uppercase shadow-lg hover:opacity-95 active:scale-[0.98] transition-all flex items-center justify-center space-x-2 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#F4E7BD]"
        >
          <span>Preview Conferral Experience</span>
          <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth="2.5" viewBox="0 0 24 24" aria-hidden="true">
            <path strokeLinecap="round" strokeLinejoin="round" d="M14 5l7 7m0 0l-7 7m7-7H3"/>
          </svg>
        </button>

      </main>

      {/* Footer */}
      <footer className="w-full max-w-xs sm:max-w-sm text-center py-1 z-20 shrink-0">
        <p className="text-[9px] text-zinc-500">
          Handshake AI Skills Studio X Google Challenge • Aegis Academic OS
        </p>
      </footer>

      {/* Spring '27 Course Breakdown Quick Sheet */}
      {showPipelineDetails && (
        <div 
          className="fixed inset-0 z-40 flex items-end justify-center p-3 bg-black/60 backdrop-blur-sm"
          onClick={() => setShowPipelineDetails(false)}
        >
          <div 
            className="glass-panel w-full max-w-xs sm:max-w-sm rounded-2xl p-4 text-left border border-white/15 max-h-[70vh] flex flex-col overflow-hidden shadow-2xl animate-fade-in"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between pb-2 border-b border-white/10 mb-2.5">
              <div>
                <h3 className="text-xs font-bold text-white uppercase tracking-wider">Spring 2027 Pipeline</h3>
                <p className="text-[10px] text-[#75ACD8]">6 Courses • 18 Credits Total</p>
              </div>
              <button 
                onClick={() => setShowPipelineDetails(false)}
                className="text-zinc-400 hover:text-white p-1"
                aria-label="Close"
              >
                <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12"/>
                </svg>
              </button>
            </div>

            <div className="overflow-y-auto space-y-2 pr-1 text-xs">
              <div className="bg-black/30 p-2 rounded-lg border border-white/5">
                <span className="text-[10px] font-mono font-bold text-[#F4E7BD]">CJUS 300</span>
                <p className="text-[11px] text-zinc-200">Administration of Justice Systems (3 cr)</p>
              </div>
              <div className="bg-black/30 p-2 rounded-lg border border-white/5">
                <span className="text-[10px] font-mono font-bold text-[#F4E7BD]">CJUS 340</span>
                <p className="text-[11px] text-zinc-200">Criminology & Behavioral Analysis (3 cr)</p>
              </div>
              <div className="bg-black/30 p-2 rounded-lg border border-white/5">
                <span className="text-[10px] font-mono font-bold text-[#F4E7BD]">CJUS 380</span>
                <p className="text-[11px] text-zinc-200">Introduction to Homeland Security (3 cr)</p>
              </div>
              <div className="bg-black/30 p-2 rounded-lg border border-white/5">
                <span className="text-[10px] font-mono font-bold text-[#F4E7BD]">CJUS 400</span>
                <p className="text-[11px] text-zinc-200">Criminal Law & Statutory Procedure (3 cr)</p>
              </div>
              <div className="bg-black/30 p-2 rounded-lg border border-white/5">
                <span className="text-[10px] font-mono font-bold text-[#F4E7BD]">CJUS 410</span>
                <p className="text-[11px] text-zinc-200">Constitutional Criminal Procedure (3 cr)</p>
              </div>
              <div className="bg-black/30 p-2 rounded-lg border border-white/5">
                <span className="text-[10px] font-mono font-bold text-[#F4E7BD]">GOVT 480</span>
                <p className="text-[11px] text-zinc-200">Terrorism & National Security Policy (3 cr)</p>
              </div>
            </div>

            <button 
              onClick={() => setShowPipelineDetails(false)}
              className="mt-3 w-full py-1.5 rounded-lg bg-white/10 text-[10px] font-bold uppercase tracking-wider text-white hover:bg-white/15"
            >
              Done
            </button>
          </div>
        </div>
      )}

      {/* Conferral Experience Modal (Isolated Showcase Preview) */}
      {showConferral && (
        <div 
          className="fixed inset-0 z-50 flex items-center justify-center p-3 bg-black/80 backdrop-blur-xl animate-fade-in"
          role="dialog"
          aria-modal="true"
          aria-label="Conferral Experience Preview"
        >
          <div className="glass-panel w-full max-w-xs sm:max-w-sm rounded-2xl p-4 sm:p-5 text-center relative border border-[#C6B386]/40 flex flex-col items-center shadow-2xl">
            
            {/* Close Button */}
            <button 
              onClick={closeConferralModal} 
              aria-label="Close Preview"
              className="absolute top-3 right-3 text-zinc-400 hover:text-white p-1.5 rounded-lg hover:bg-white/10 transition-colors"
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>

            {/* Subtitle / Mode Indicator */}
            <div className="flex items-center gap-1.5 mb-0.5">
              <span className="text-[9px] font-bold tracking-[0.2em] text-[#75ACD8] uppercase font-mono">
                {conferralStatus}
              </span>
              <button 
                onClick={() => setSoundEnabled(!soundEnabled)}
                title={soundEnabled ? "Audio Fanfare Enabled" : "Audio Fanfare Muted"}
                className="text-zinc-400 hover:text-[#C6B386] transition-colors p-0.5"
                aria-label="Toggle ceremonial fanfare audio"
              >
                {soundEnabled ? (
                  <svg className="w-3 h-3 text-[#C6B386]" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M15.536 8.464a5 5 0 010 7.072m2.828-9.9a9 9 0 010 12.728M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" />
                  </svg>
                ) : (
                  <svg className="w-3 h-3 text-zinc-500" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" />
                    <path strokeLinecap="round" strokeLinejoin="round" d="M17 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2" />
                  </svg>
                )}
              </button>
            </div>

            {/* Preview Banner: clearly states simulation */}
            <p className="text-[9px] text-zinc-400 mb-1 font-mono">
              [CONFERRAL SIMULATION · TARGET AUGUST 20, 2027]
            </p>
            
            {/* Animated Credits Counter */}
            <div className="my-1.5">
              <span className="text-4xl sm:text-5xl font-black font-serif text-white tracking-tight tabular-nums">
                {previewCredits}
              </span>
              <span className="text-lg font-bold text-[#C6B386]"> / 121</span>
            </div>

            {/* Regalia / Cap Graphic representation */}
            <div className="my-2.5 relative flex items-center justify-center w-24 h-18">
              <div className="absolute inset-0 bg-[#C6B386]/10 rounded-full blur-lg animate-pulse pointer-events-none" />
              <svg 
                className={`w-20 h-20 transform transition-all duration-700 drop-shadow-xl ${
                  isConferred ? 'scale-100 rotate-0' : 'scale-75 -rotate-6'
                }`} 
                viewBox="0 0 100 60" 
                fill="none" 
                xmlns="http://www.w3.org/2000/svg"
              >
                <path d="M50 10L90 25L50 40L10 25L50 10Z" fill="url(#goldGradModal)" stroke="#F4E7BD" strokeWidth="1.5"/>
                <path d="M35 33C35 45 65 45 65 33V30H35V33Z" fill="#4C3E26"/>
                {/* Tassel turn: flips from right to left upon conferral */}
                {isConferred ? (
                  <path d="M30 28L20 45" stroke="#081F42" strokeWidth="2.5" strokeLinecap="round"/>
                ) : (
                  <path d="M70 28L80 45" stroke="#081F42" strokeWidth="2.5" strokeLinecap="round"/>
                )}
                <circle cx="50" cy="25" r="3" fill="#F4E7BD"/>
                <defs>
                  <linearGradient id="goldGradModal" x1="10" y1="10" x2="90" y2="40" gradientUnits="userSpaceOnUse">
                    <stop stopColor="#F4E7BD"/>
                    <stop offset="0.5" stopColor="#C6B386"/>
                    <stop offset="1" stopColor="#806D43"/>
                  </linearGradient>
                </defs>
              </svg>
            </div>

            {/* Seal / Honors Stamp */}
            <div className={`liquid-glass-seal rounded-xl p-3 w-full mt-1 transition-all duration-500 ${
              isConferred ? 'opacity-100 translate-y-0 shadow-lg' : 'opacity-40 translate-y-1'
            }`}>
              <h3 className="text-base font-black font-serif text-[#F4E7BD] tracking-wider leading-tight">
                DEGREE CONFERRED
              </h3>
              <p className="text-[11px] font-bold text-white tracking-widest mt-0.5">SUMMA CUM LAUDE</p>
              <p className="text-[9px] font-mono text-[#75ACD8] mt-0.5">FINAL CUMULATIVE GPA: 4.00</p>
              <p className="text-[8px] text-zinc-300 mt-0.5 uppercase tracking-wider">
                Liberty University • B.S. in Criminal Justice
              </p>
            </div>

            {/* Modal Actions */}
            <div className="mt-4 w-full flex space-x-2">
              <button 
                onClick={runConferralSequence} 
                className="flex-1 py-2.5 rounded-lg bg-white/10 hover:bg-white/20 text-[10px] font-bold tracking-wider uppercase transition-all"
              >
                Replay Preview
              </button>
              <button 
                onClick={closeConferralModal} 
                className="flex-1 py-2.5 rounded-lg bg-[#B72025] hover:bg-[#B72025]/90 text-white text-[10px] font-bold tracking-wider uppercase transition-all shadow-md"
              >
                Return to OS
              </button>
            </div>

          </div>
        </div>
      )}

    </div>
  );
}
