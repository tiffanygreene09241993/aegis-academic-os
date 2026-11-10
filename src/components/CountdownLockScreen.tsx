import React, { useState, useEffect } from 'react';
import { TARGET_GRADUATION_DATE, ACADEMIC_PROFILE } from '../data/degreeData';
import { Calendar, GraduationCap, Flame, Clock } from 'lucide-react';

interface CountdownLockScreenProps {
  currentCredits?: number;
  onOpenConferral: () => void;
}

export const CountdownLockScreen: React.FC<CountdownLockScreenProps> = ({
  currentCredits = 94,
  onOpenConferral,
}) => {
  const [countdown, setCountdown] = useState({
    days: '284',
    hours: '14',
    minutes: '32',
    seconds: '00',
  });

  const [simulatedCredits, setSimulatedCredits] = useState<number>(currentCredits);
  const [isSimulating, setIsSimulating] = useState<boolean>(false);

  useEffect(() => {
    const calculateCountdown = () => {
      const targetTime = new Date(TARGET_GRADUATION_DATE).getTime();
      const now = new Date().getTime();
      const distance = targetTime - now;

      if (distance > 0) {
        const d = Math.floor(distance / (1000 * 60 * 60 * 24));
        const h = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        const m = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
        const s = Math.floor((distance % (1000 * 60)) / 1000);

        setCountdown({
          days: d.toString(),
          hours: h.toString().padStart(2, '0'),
          minutes: m.toString().padStart(2, '0'),
          seconds: s.toString().padStart(2, '0'),
        });
      } else {
        setCountdown({ days: '0', hours: '00', minutes: '00', seconds: '00' });
      }
    };

    calculateCountdown();
    const interval = setInterval(calculateCountdown, 1000);
    return () => clearInterval(interval);
  }, []);

  const effectiveCredits = isSimulating ? simulatedCredits : currentCredits;
  const percentage = Math.min(100, Math.round((effectiveCredits / ACADEMIC_PROFILE.totalCredits) * 100));

  return (
    <div className="glass-panel rounded-3xl p-6 sm:p-7 relative overflow-hidden text-center transition-all">
      {/* Decorative Background Glows */}
      <div className="absolute -top-12 -right-12 w-40 h-40 bg-[#C6B386]/15 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute -bottom-16 -left-16 w-44 h-44 bg-[#B72025]/15 rounded-full blur-3xl pointer-events-none" />

      {/* Target Badge & Institutional Marker */}
      <div className="flex items-center justify-between gap-2 mb-3">
        <span className="text-[11px] font-bold tracking-[0.2em] text-[#75ACD8] uppercase flex items-center gap-1.5">
          <Clock className="w-3.5 h-3.5 text-[#75ACD8]" />
          Target: {ACADEMIC_PROFILE.targetDateStr}
        </span>
        <span className="text-[10px] font-mono tracking-wider text-slate-400">
          CONFERRAL DATE
        </span>
      </div>

      {/* Live Countdown Grid with Tabular Numerals */}
      <div className="grid grid-cols-4 gap-2 sm:gap-3 my-4">
        <div className="bg-black/40 rounded-2xl p-3 sm:p-4 border border-white/5 backdrop-blur-sm">
          <span className="text-2xl sm:text-4xl font-black font-mono tabular-nums tracking-tight text-white">
            {countdown.days}
          </span>
          <p className="text-[10px] uppercase tracking-wider text-slate-400 mt-1">Days</p>
        </div>

        <div className="bg-black/40 rounded-2xl p-3 sm:p-4 border border-white/5 backdrop-blur-sm">
          <span className="text-2xl sm:text-4xl font-black font-mono tabular-nums tracking-tight text-white">
            {countdown.hours}
          </span>
          <p className="text-[10px] uppercase tracking-wider text-slate-400 mt-1">Hours</p>
        </div>

        <div className="bg-black/40 rounded-2xl p-3 sm:p-4 border border-white/5 backdrop-blur-sm">
          <span className="text-2xl sm:text-4xl font-black font-mono tabular-nums tracking-tight text-white">
            {countdown.minutes}
          </span>
          <p className="text-[10px] uppercase tracking-wider text-slate-400 mt-1">Mins</p>
        </div>

        <div className="bg-black/40 rounded-2xl p-3 sm:p-4 border border-white/5 backdrop-blur-sm">
          <span className="text-2xl sm:text-4xl font-black font-mono tabular-nums tracking-tight text-[#C6B386]">
            {countdown.seconds}
          </span>
          <p className="text-[10px] uppercase tracking-wider text-slate-400 mt-1">Secs</p>
        </div>
      </div>

      {/* Progress Telemetry */}
      <div className="mt-5 pt-4 border-t border-white/10 flex items-center justify-between">
        <div className="text-left">
          <p className="text-xs font-semibold text-slate-300">Degree Progress</p>
          <p className="text-xl sm:text-2xl font-black text-white font-mono tabular-nums tracking-tight">
            {effectiveCredits} <span className="text-slate-400 font-normal">/</span> {ACADEMIC_PROFILE.totalCredits}{' '}
            <span className="text-xs font-medium text-[#75ACD8] font-sans">Credits</span>
          </p>
        </div>
        <div className="text-right">
          <span className="px-3 py-1 rounded-full bg-[#B72025]/20 border border-[#B72025]/40 text-[#EF4444] text-xs font-bold tracking-wide">
            {percentage}% Complete
          </span>
        </div>
      </div>

      {/* Progress Bar with smooth gradient transition */}
      <div className="w-full bg-black/50 h-2.5 rounded-full overflow-hidden mt-3 border border-white/5">
        <div
          className="bg-gradient-to-r from-[#75ACD8] via-[#C6B386] to-[#F4E7BD] h-full transition-all duration-700 ease-out shadow-[0_0_12px_rgba(198,179,134,0.4)]"
          style={{ width: `${percentage}%` }}
        />
      </div>

      {/* Interactive Credit Velocity Simulator Drawer / Toggle */}
      <div className="mt-4 pt-3 flex flex-wrap items-center justify-between text-xs text-slate-400 gap-2">
        <div className="flex items-center gap-2">
          <button
            onClick={() => {
              setIsSimulating(!isSimulating);
              if (!isSimulating) setSimulatedCredits(94);
            }}
            className="text-[11px] font-semibold text-[#75ACD8] hover:text-white transition-colors underline underline-offset-2 cursor-pointer"
          >
            {isSimulating ? 'Reset to Actual (94 Credits)' : 'Simulate Course Completion'}
          </button>
        </div>
        <span className="text-[11px] font-mono text-slate-400">
          {ACADEMIC_PROFILE.totalCredits - effectiveCredits} Credits to Conferral
        </span>
      </div>

      {isSimulating && (
        <div className="mt-3 p-3 bg-black/40 rounded-2xl border border-white/10 text-left animate-in fade-in duration-200">
          <div className="flex justify-between text-xs mb-1.5 font-medium">
            <span className="text-slate-300">Simulate Completed Credits:</span>
            <span className="text-[#C6B386] font-mono font-bold">{simulatedCredits} / 121</span>
          </div>
          <input
            type="range"
            min="94"
            max="121"
            step="3"
            value={simulatedCredits}
            onChange={(e) => setSimulatedCredits(Number(e.target.value))}
            className="w-full accent-[#C6B386] cursor-pointer"
          />
          <div className="flex justify-between text-[10px] text-slate-400 mt-1">
            <span>94 (Spring Start)</span>
            <span>112 (Spring Finished)</span>
            <span>121 (Conferred)</span>
          </div>
          {simulatedCredits === 121 && (
            <div className="mt-2 text-center">
              <button
                onClick={onOpenConferral}
                className="w-full py-2 bg-[#C6B386] text-[#0A254E] font-extrabold text-xs uppercase tracking-wider rounded-xl shadow-lg hover:bg-white transition-all"
              >
                Launch Conferral Ceremony Now
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
};
