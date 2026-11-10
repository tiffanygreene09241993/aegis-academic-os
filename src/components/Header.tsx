import React from 'react';
import { Award } from 'lucide-react';

interface HeaderProps {
  activeTab: 'milestones' | 'audit' | 'pipeline' | 'honors';
  onSelectTab: (tab: 'milestones' | 'audit' | 'pipeline' | 'honors') => void;
  onOpenConferral: () => void;
}

export const Header: React.FC<HeaderProps> = ({ activeTab, onSelectTab, onOpenConferral }) => {
  return (
    <header className="w-full border-b border-white/10 bg-[#071731]/90 backdrop-blur-md sticky top-0 z-40">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between gap-8">
        
        {/* Zone 1: Single text element wordmark */}
        <a 
          href="#home" 
          onClick={(e) => { e.preventDefault(); onSelectTab('milestones'); }}
          className="text-base sm:text-lg font-black tracking-widest text-[#75ACD8] uppercase whitespace-nowrap shrink-0 flex items-center gap-2 hover:text-white transition-colors"
        >
          <span className="w-2.5 h-2.5 rounded-full bg-[#B72025] inline-block shadow-[0_0_8px_rgba(183,32,37,0.8)]" />
          <span>Aegis Academic OS</span>
        </a>

        {/* Zone 2: 4-5 concise single-line nav links with hover underlines */}
        <nav className="hidden md:flex items-center gap-7 text-xs font-semibold tracking-wider uppercase text-slate-300">
          <button
            onClick={() => onSelectTab('milestones')}
            className={`whitespace-nowrap shrink-0 transition-colors py-1 relative ${
              activeTab === 'milestones' ? 'text-[#C6B386]' : 'hover:text-white'
            }`}
          >
            Milestones
            {activeTab === 'milestones' && (
              <span className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#C6B386]" />
            )}
          </button>

          <button
            onClick={() => onSelectTab('pipeline')}
            className={`whitespace-nowrap shrink-0 transition-colors py-1 relative ${
              activeTab === 'pipeline' ? 'text-[#C6B386]' : 'hover:text-white'
            }`}
          >
            Spring '27 Pipeline
            {activeTab === 'pipeline' && (
              <span className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#C6B386]" />
            )}
          </button>

          <button
            onClick={() => onSelectTab('audit')}
            className={`whitespace-nowrap shrink-0 transition-colors py-1 relative ${
              activeTab === 'audit' ? 'text-[#C6B386]' : 'hover:text-white'
            }`}
          >
            Degree Audit
            {activeTab === 'audit' && (
              <span className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#C6B386]" />
            )}
          </button>

          <button
            onClick={() => onSelectTab('honors')}
            className={`whitespace-nowrap shrink-0 transition-colors py-1 relative ${
              activeTab === 'honors' ? 'text-[#C6B386]' : 'hover:text-white'
            }`}
          >
            Honors & Regalia
            {activeTab === 'honors' && (
              <span className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#C6B386]" />
            )}
          </button>
        </nav>

        {/* Zone 3: 1 primary action */}
        <div className="flex items-center gap-3 shrink-0">
          <button
            onClick={onOpenConferral}
            className="px-4 py-2 text-xs font-extrabold uppercase tracking-wider text-[#0A254E] bg-gradient-to-r from-[#F4E7BD] via-[#C6B386] to-[#A38E5B] rounded-xl hover:shadow-[0_0_20px_rgba(198,179,134,0.4)] active:scale-[0.98] transition-all whitespace-nowrap shrink-0 flex items-center gap-1.5"
          >
            <Award className="w-3.5 h-3.5" />
            <span>Preview Conferral</span>
          </button>
        </div>

      </div>
    </header>
  );
};
