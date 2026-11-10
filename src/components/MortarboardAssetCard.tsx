import React, { useState } from 'react';
import { Sparkles, Shield, RefreshCw } from 'lucide-react';
import { playTickChime } from '../utils/audioCelebration';

interface MortarboardAssetCardProps {
  interactiveTassel?: boolean;
}

export const MortarboardAssetCard: React.FC<MortarboardAssetCardProps> = ({
  interactiveTassel = true,
}) => {
  const [tasselSide, setTasselSide] = useState<'right' | 'left'>('right');
  const [isRotating, setIsRotating] = useState<boolean>(false);

  const toggleTassel = () => {
    playTickChime();
    setIsRotating(true);
    setTasselSide((prev) => (prev === 'right' ? 'left' : 'right'));
    setTimeout(() => setIsRotating(false), 500);
  };

  return (
    <div className="glass-panel rounded-2xl p-5 sm:p-6 text-center relative flex flex-col items-center justify-center min-h-[160px] overflow-hidden group">
      {/* Background ambient radial glow */}
      <div className="absolute inset-0 bg-gradient-to-b from-[#C6B386]/10 via-transparent to-transparent pointer-events-none" />

      {/* Interactive Champagne Gold Cap SVG Icon */}
      <div 
        onClick={interactiveTassel ? toggleTassel : undefined}
        className={`relative cursor-pointer transition-transform duration-500 my-1 ${
          isRotating ? 'scale-110' : 'hover:scale-105'
        }`}
        title="Click to turn ceremonial tassel!"
      >
        <div className="absolute inset-0 bg-[#C6B386]/20 rounded-full blur-xl scale-75 animate-pulse" />
        
        <svg 
          className="w-20 h-20 sm:w-24 sm:h-24 drop-shadow-[0_12px_24px_rgba(198,179,134,0.35)] relative z-10 transition-transform duration-500" 
          viewBox="0 0 100 65" 
          fill="none" 
          xmlns="http://www.w3.org/2000/svg"
        >
          {/* Mortarboard Diamond Crown */}
          <path 
            d="M50 8L92 24L50 40L8 24L50 8Z" 
            fill="url(#goldCapGrad)" 
            stroke="#F4E7BD" 
            strokeWidth="1.5" 
          />
          {/* Skullcap / Headband */}
          <path 
            d="M32 32C32 46 68 46 68 32V28H32V32Z" 
            fill="#3F321E" 
            stroke="#C6B386"
            strokeWidth="0.8"
          />
          {/* Cap Button / Center Stud */}
          <circle cx="50" cy="24" r="3.2" fill="#F4E7BD" stroke="#806D43" strokeWidth="1" />

          {/* Dynamic Tassel: Right side (Candidate) vs Left side (Graduate) */}
          {tasselSide === 'right' ? (
            <g className="transition-all duration-500">
              {/* Tassel cord right */}
              <path 
                d="M50 24 Q65 24 74 36" 
                stroke="#C6B386" 
                strokeWidth="1.8" 
                strokeLinecap="round" 
                fill="none" 
              />
              {/* Tassel drop & 2027 charm */}
              <line x1="74" y1="36" x2="82" y2="52" stroke="#F4E7BD" strokeWidth="2.8" strokeLinecap="round" />
              {/* Charm ornament */}
              <circle cx="82" cy="53" r="2.2" fill="#B72025" />
            </g>
          ) : (
            <g className="transition-all duration-500">
              {/* Tassel cord left (Degree Conferred tradition!) */}
              <path 
                d="M50 24 Q35 24 26 36" 
                stroke="#C6B386" 
                strokeWidth="1.8" 
                strokeLinecap="round" 
                fill="none" 
              />
              {/* Tassel drop & 2027 charm */}
              <line x1="26" y1="36" x2="18" y2="52" stroke="#F4E7BD" strokeWidth="2.8" strokeLinecap="round" />
              {/* Charm ornament */}
              <circle cx="18" cy="53" r="2.2" fill="#B72025" />
            </g>
          )}

          <defs>
            <linearGradient id="goldCapGrad" x1="8" y1="8" x2="92" y2="40" gradientUnits="userSpaceOnUse">
              <stop stopColor="#FFF2D6" />
              <stop offset="0.3" stopColor="#E0CF9E" />
              <stop offset="0.7" stopColor="#C6B386" />
              <stop offset="1" stopColor="#7E683A" />
            </linearGradient>
          </defs>
        </svg>

        {interactiveTassel && (
          <div className="text-[10px] font-mono text-[#C6B386] mt-1 flex items-center justify-center gap-1 opacity-80 group-hover:opacity-100 transition-opacity">
            <RefreshCw className="w-2.5 h-2.5" />
            <span>Tassel: {tasselSide === 'right' ? 'Candidate (Right)' : 'Conferred Graduate (Left)'}</span>
          </div>
        )}
      </div>

      <p className="text-xs font-bold text-[#C6B386] tracking-wider uppercase mt-2">
        Champagne-Gold Mortarboard
      </p>
      <div className="flex items-center gap-1.5 text-[10px] text-slate-300 mt-1">
        <Shield className="w-3 h-3 text-[#75ACD8]" />
        <span>Omega Nu Lambda & Sword & Shield Honored</span>
      </div>
      <p className="text-[10px] text-slate-400 mt-0.5">
        Custom collegiate regalia · Liberty University BS-CJ Class of 2027
      </p>
    </div>
  );
};
