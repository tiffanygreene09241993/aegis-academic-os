import React, { useState, useEffect, useRef } from 'react';
import confetti from 'canvas-confetti';
import { X, RotateCcw, Award, CheckCircle2, Volume2, VolumeX, Printer, Download } from 'lucide-react';
import { playGraduationFanfare, playTickChime } from '../utils/audioCelebration';
import { ACADEMIC_PROFILE } from '../data/degreeData';

interface ConferralModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export const ConferralModal: React.FC<ConferralModalProps> = ({ isOpen, onClose }) => {
  const [previewCredits, setPreviewCredits] = useState<number>(112);
  const [conferralStatus, setConferralStatus] = useState<string>('ACADEMIC DISTINCTIONS VERIFIED');
  const [isConferred, setIsConferred] = useState<boolean>(false);
  const [isMuted, setIsMuted] = useState<boolean>(false);
  const [showCertificateView, setShowCertificateView] = useState<boolean>(false);
  const timersRef = useRef<NodeJS.Timeout[]>([]);

  const clearAllTimers = () => {
    timersRef.current.forEach((t) => clearTimeout(t));
    timersRef.current = [];
  };

  const launchConfetti = () => {
    // Elegant champagne gold & academic navy/crimson confetti
    const colors = ['#C6B386', '#F4E7BD', '#B72025', '#75ACD8', '#FFFFFF'];
    
    confetti({
      particleCount: 80,
      spread: 70,
      origin: { y: 0.6 },
      colors,
      ticks: 200,
      gravity: 0.8,
      scalar: 1.1,
    });

    setTimeout(() => {
      confetti({
        particleCount: 50,
        angle: 60,
        spread: 55,
        origin: { x: 0 },
        colors,
      });
      confetti({
        particleCount: 50,
        angle: 120,
        spread: 55,
        origin: { x: 1 },
        colors,
      });
    }, 400);
  };

  const runSequence = () => {
    clearAllTimers();
    setPreviewCredits(112);
    setConferralStatus('ACADEMIC DISTINCTIONS VERIFIED');
    setIsConferred(false);
    setShowCertificateView(false);

    // Step 1: Conferring phase at 800ms
    const t1 = setTimeout(() => {
      setConferralStatus('CONFERRING DEGREE');
      playTickChime();

      // Step-by-step credit resolution
      const t2 = setTimeout(() => {
        setPreviewCredits(115);
        playTickChime();
      }, 400);

      const t3 = setTimeout(() => {
        setPreviewCredits(118);
        playTickChime();
      }, 800);

      const t4 = setTimeout(() => {
        setPreviewCredits(121);
        setConferralStatus('REQUIREMENTS SATISFIED');
        setIsConferred(true);
        playGraduationFanfare(isMuted);
        launchConfetti();
      }, 1200);

      timersRef.current.push(t2, t3, t4);
    }, 800);

    timersRef.current.push(t1);
  };

  useEffect(() => {
    if (isOpen) {
      runSequence();
    } else {
      clearAllTimers();
    }
    return () => clearAllTimers();
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div 
      className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-4 bg-black/85 backdrop-blur-xl animate-in fade-in duration-300"
      onClick={(e) => {
        if (e.target === e.currentTarget) onClose();
      }}
    >
      <div className="glass-panel w-full max-w-lg rounded-3xl p-6 sm:p-8 text-center relative border border-[#C6B386]/40 flex flex-col items-center shadow-[0_25px_60px_rgba(0,0,0,0.7)] max-h-[92vh] overflow-y-auto">
        
        {/* Audio Mute & Close Controls */}
        <div className="absolute top-4 right-4 flex items-center gap-1">
          <button
            onClick={() => setIsMuted(!isMuted)}
            className="text-slate-400 hover:text-white p-2 rounded-xl hover:bg-white/10 transition-colors"
            title={isMuted ? 'Unmute ceremonial fanfare' : 'Mute audio'}
            aria-label="Toggle Sound"
          >
            {isMuted ? <VolumeX className="w-4 h-4 text-slate-400" /> : <Volume2 className="w-4 h-4 text-[#C6B386]" />}
          </button>

          <button
            onClick={onClose}
            className="text-slate-400 hover:text-white p-2 rounded-xl hover:bg-white/10 transition-colors"
            aria-label="Close modal"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Status Kicker */}
        <div className="mt-1 flex items-center gap-2">
          {isConferred && <CheckCircle2 className="w-3.5 h-3.5 text-[#C6B386]" />}
          <p className="text-[11px] font-bold tracking-[0.25em] text-[#75ACD8] uppercase font-mono">
            {conferralStatus}
          </p>
        </div>

        {!showCertificateView ? (
          <>
            {/* Animated Credits Counter */}
            <div className="my-4">
              <span className="text-5xl sm:text-6xl font-black font-serif text-white tracking-tight">
                {previewCredits}
              </span>
              <span className="text-2xl sm:text-3xl font-bold text-[#C6B386]">
                {' '}/ {ACADEMIC_PROFILE.totalCredits}
              </span>
              <p className="text-xs uppercase tracking-widest text-slate-400 mt-1 font-mono">
                Baccalaureate Credits Resolved
              </p>
            </div>

            {/* Mortarboard Dynamic Graphic */}
            <div className="my-3 relative flex items-center justify-center w-36 h-28">
              <div 
                className={`absolute inset-0 bg-[#C6B386]/20 rounded-full blur-2xl transition-all duration-700 ${
                  isConferred ? 'scale-125 opacity-100' : 'scale-90 opacity-40'
                }`} 
              />
              <svg
                className={`w-28 h-28 transform transition-all duration-700 drop-shadow-2xl ${
                  isConferred ? 'scale-110 rotate-0' : 'scale-85 -rotate-6'
                }`}
                viewBox="0 0 100 60"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                {/* Mortarboard Diamond */}
                <path d="M50 10L90 25L50 40L10 25L50 10Z" fill="url(#goldGradModal)" stroke="#F4E7BD" strokeWidth="1.5" />
                {/* Skullcap */}
                <path d="M35 33C35 45 65 45 65 33V30H35V33Z" fill="#3D301C" />
                {/* Tassel: Shifts to left side once conferred! */}
                {isConferred ? (
                  <path d="M50 25 Q32 25 24 45" stroke="#F4E7BD" strokeWidth="2.5" strokeLinecap="round" />
                ) : (
                  <path d="M50 25 Q68 25 78 45" stroke="#081F42" strokeWidth="2.5" strokeLinecap="round" />
                )}
                <circle cx="50" cy="25" r="3" fill="#F4E7BD" />
                <defs>
                  <linearGradient id="goldGradModal" x1="10" y1="10" x2="90" y2="40" gradientUnits="userSpaceOnUse">
                    <stop stopColor="#FFF2D6" />
                    <stop offset="0.5" stopColor="#C6B386" />
                    <stop offset="1" stopColor="#806D43" />
                  </linearGradient>
                </defs>
              </svg>
            </div>

            {/* Seal / Honors Stamp */}
            <div 
              className={`liquid-glass-seal rounded-2xl p-5 w-full mt-2 transition-all duration-700 ${
                isConferred ? 'opacity-100 translate-y-0 scale-100' : 'opacity-40 translate-y-2 scale-98'
              }`}
            >
              <div className="w-8 h-8 mx-auto mb-1.5 rounded-full bg-[#C6B386]/20 border border-[#C6B386]/40 flex items-center justify-center">
                <Award className="w-4 h-4 text-[#F4E7BD]" />
              </div>
              <h3 className="text-xl sm:text-2xl font-black font-serif text-[#F4E7BD] tracking-wider">
                DEGREE CONFERRED
              </h3>
              <p className="text-sm font-bold text-white tracking-widest mt-1">
                {ACADEMIC_PROFILE.degree}
              </p>
              <div className="flex items-center justify-center gap-2 mt-2 text-xs font-semibold text-[#75ACD8]">
                <span>{ACADEMIC_PROFILE.institution}</span>
                <span>·</span>
                <span className="text-[#C6B386]">{ACADEMIC_PROFILE.academicStanding}</span>
              </div>
              <p className="text-[11px] font-mono text-slate-300 mt-1">
                FINAL CUMULATIVE GPA: {ACADEMIC_PROFILE.cumulativeGpa} · 121 / 121 CREDITS
              </p>
            </div>

            {/* Certificate Preview Button */}
            {isConferred && (
              <button
                onClick={() => setShowCertificateView(true)}
                className="mt-3 text-xs font-bold text-[#F4E7BD] hover:text-white underline underline-offset-4 tracking-wide transition-colors cursor-pointer"
              >
                Inspect Official Commencement Diploma
              </button>
            )}
          </>
        ) : (
          /* Official Commencement Diploma View */
          <div className="w-full my-2 bg-[#FBF9F3] text-slate-900 rounded-2xl p-6 sm:p-7 border-4 border-double border-[#C6B386] shadow-2xl relative text-center animate-in zoom-in-95 duration-300">
            <p className="text-[11px] font-mono tracking-[0.25em] text-[#0A254E] uppercase font-bold">
              LIBERTY UNIVERSITY
            </p>
            <p className="text-[9px] uppercase tracking-wider text-slate-500 mt-0.5">
              Lynchburg, Commonwealth of Virginia
            </p>

            <div className="my-4">
              <p className="text-xs italic text-slate-600 font-serif">
                By authority of the Board of Trustees and upon recommendation of the Faculty, has conferred upon
              </p>
              <p className="text-2xl sm:text-3xl font-serif font-black text-[#0A254E] tracking-tight my-2">
                Aegis Academic Scholar
              </p>
              <p className="text-xs text-slate-600 font-serif">the degree of</p>
              <p className="text-lg sm:text-xl font-bold font-serif text-[#B72025] mt-1">
                Bachelor of Science in Criminal Justice
              </p>
              <p className="text-xs font-semibold text-slate-700 mt-1">
                With Highest Distinction · Summa Cum Laude
              </p>
            </div>

            <div className="pt-3 border-t border-[#C6B386]/50 flex items-center justify-between text-[10px] text-slate-600 font-serif">
              <div>
                <p className="font-bold text-[#0A254E]">Omega Nu Lambda</p>
                <p>Sword & Shield Honored</p>
              </div>
              <div className="w-12 h-12 rounded-full border-2 border-[#C6B386] bg-[#C6B386]/20 flex items-center justify-center font-bold text-[#806D43] text-[9px] shadow-sm">
                SEAL
              </div>
              <div className="text-right">
                <p className="font-bold text-[#0A254E]">August 20, 2027</p>
                <p>Conferral Date</p>
              </div>
            </div>

            <div className="mt-4 flex items-center justify-center gap-2">
              <button
                onClick={() => window.print()}
                className="px-3 py-1.5 rounded-lg bg-[#0A254E] text-white text-[11px] font-bold flex items-center gap-1.5 hover:bg-[#071731] transition-colors"
              >
                <Printer className="w-3.5 h-3.5" />
                <span>Print Diploma</span>
              </button>
              <button
                onClick={() => setShowCertificateView(false)}
                className="px-3 py-1.5 rounded-lg bg-slate-200 text-slate-800 text-[11px] font-bold hover:bg-slate-300 transition-colors"
              >
                Back to Animation
              </button>
            </div>
          </div>
        )}

        {/* Modal Actions */}
        <div className="mt-6 w-full flex space-x-3">
          <button
            onClick={runSequence}
            className="flex-1 py-3.5 rounded-xl bg-white/10 hover:bg-white/20 text-xs font-bold tracking-wider uppercase transition-all flex items-center justify-center gap-1.5 text-white cursor-pointer"
          >
            <RotateCcw className="w-3.5 h-3.5" />
            <span>Replay Preview</span>
          </button>

          <button
            onClick={onClose}
            className="flex-1 py-3.5 rounded-xl bg-[#B72025] hover:bg-[#991B1F] text-white text-xs font-bold tracking-wider uppercase transition-all shadow-lg shadow-[#B72025]/30 cursor-pointer"
          >
            Return to OS
          </button>
        </div>

      </div>
    </div>
  );
};
