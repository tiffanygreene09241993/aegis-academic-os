import React from 'react';
import { HONOR_SOCIETIES, REGALIA_INVENTORY } from '../data/degreeData';
import { Shield, Award, CheckCircle, Sparkles, Feather } from 'lucide-react';
import { MortarboardAssetCard } from './MortarboardAssetCard';

export const HonorsVaultView: React.FC = () => {
  return (
    <div className="space-y-6">
      {/* Title & Introduction */}
      <div>
        <h2 className="text-xl font-bold font-serif text-[#F4E7BD] tracking-wide">
          Academic Honors & Regalia Distinction Vault
        </h2>
        <p className="text-xs text-slate-400 mt-1">
          Certified Honor Societies, Latin Honors Qualification, and Official Commencement Attire
        </p>
      </div>

      {/* Featured Honor Societies Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {HONOR_SOCIETIES.map((society) => (
          <div key={society.id} className="glass-panel rounded-2xl p-5 border border-[#C6B386]/30 flex flex-col justify-between">
            <div>
              <div className="flex items-start justify-between gap-3 mb-2">
                <div className="flex items-center gap-2.5">
                  <div className="w-10 h-10 rounded-xl bg-[#C6B386]/20 border border-[#C6B386]/40 flex items-center justify-center text-[#C6B386]">
                    <Shield className="w-5 h-5" />
                  </div>
                  <div>
                    <h3 className="text-sm font-bold text-white">{society.name}</h3>
                    <p className="text-[11px] font-mono text-[#75ACD8]">{society.abbreviation}</p>
                  </div>
                </div>
                <span className="px-2.5 py-0.5 rounded-full bg-emerald-500/15 border border-emerald-500/30 text-emerald-400 text-[10px] font-bold whitespace-nowrap">
                  {society.status}
                </span>
              </div>

              <p className="text-xs text-slate-300 mt-3 leading-relaxed">
                {society.description}
              </p>

              <div className="mt-4 pt-3 border-t border-white/10 space-y-1.5 text-xs">
                <div className="flex justify-between">
                  <span className="text-slate-400">Discipline:</span>
                  <span className="text-slate-200 font-medium">{society.discipline}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-400">Academic Criteria:</span>
                  <span className="text-[#C6B386] font-medium font-mono text-[11px]">{society.gpaRequirement}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-400">Inducted:</span>
                  <span className="text-slate-300 font-mono text-[11px]">{society.inductedDate}</span>
                </div>
              </div>
            </div>

            <div className="mt-4 p-2.5 bg-black/40 rounded-xl border border-white/5 text-[11px] flex items-center gap-2 text-slate-300">
              <Sparkles className="w-3.5 h-3.5 text-[#C6B386] shrink-0" />
              <span>{society.regaliaCords}</span>
            </div>
          </div>
        ))}
      </div>

      {/* Regalia Spotlight */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 items-stretch">
        {/* Interactive Mortarboard Card */}
        <div className="lg:col-span-1">
          <MortarboardAssetCard interactiveTassel={true} />
        </div>

        {/* Regalia Ensemble Items */}
        <div className="lg:col-span-2 glass-panel rounded-2xl p-5 border border-white/10">
          <h3 className="text-sm font-bold text-white mb-3 flex items-center gap-2">
            <Feather className="w-4 h-4 text-[#C6B386]" />
            <span>Commencement Regalia Ensemble Specification</span>
          </h3>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            {REGALIA_INVENTORY.map((reg, idx) => (
              <div key={idx} className="bg-black/30 rounded-xl p-3 border border-white/5 text-xs">
                <div className="flex items-center justify-between mb-1">
                  <span className="font-bold text-white">{reg.item}</span>
                  <span className="text-[10px] text-[#C6B386] font-mono font-semibold">{reg.status}</span>
                </div>
                <p className="text-[11px] text-[#75ACD8] font-medium">{reg.distinction}</p>
                <p className="text-[10px] text-slate-400 mt-1 leading-snug">{reg.detail}</p>
              </div>
            ))}
          </div>

          <div className="mt-4 pt-3 border-t border-white/10 flex items-center justify-between text-xs text-slate-400">
            <span>Official Liberty University Regalia Code: Flames Baccalaureate</span>
            <span className="text-[#C6B386] font-mono text-[11px]">Class of 2027</span>
          </div>
        </div>
      </div>
    </div>
  );
};
