import React, { useState } from 'react';
import { SPRING_PIPELINE_COURSES, REMAINING_COURSES } from '../data/degreeData';
import { ChevronDown, ChevronUp, BookOpen, Sparkles, CheckCircle2 } from 'lucide-react';

interface SpringPipelineCardProps {
  onViewFullAudit?: () => void;
}

export const SpringPipelineCard: React.FC<SpringPipelineCardProps> = ({ onViewFullAudit }) => {
  const [isExpanded, setIsExpanded] = useState<boolean>(false);

  return (
    <div className="glass-panel rounded-2xl p-4 sm:p-5 transition-all">
      {/* Primary Row / Collapsed State */}
      <div 
        onClick={() => setIsExpanded(!isExpanded)}
        className="flex items-center justify-between cursor-pointer select-none group"
      >
        <div className="flex items-center space-x-3.5">
          <div className="w-11 h-11 rounded-xl bg-[#C6B386]/20 border border-[#C6B386]/40 flex items-center justify-center text-[#C6B386] font-bold text-sm shadow-[0_0_12px_rgba(198,179,134,0.15)] group-hover:scale-105 transition-transform">
            '27
          </div>
          <div>
            <div className="flex items-center gap-2">
              <p className="text-sm font-bold text-white group-hover:text-[#75ACD8] transition-colors">
                Spring 2027 Pipeline
              </p>
              <span className="text-[10px] px-2 py-0.5 rounded-md bg-[#75ACD8]/20 text-[#75ACD8] font-semibold border border-[#75ACD8]/30">
                18 Active Credits
              </span>
            </div>
            <p className="text-xs text-slate-300 mt-0.5">
              18 Active Credits · 9 Req. Remaining
            </p>
          </div>
        </div>

        <div className="flex items-center gap-3">
          <div className="text-right">
            <span className="text-xs font-mono font-bold text-[#C6B386] tracking-wider block">
              SUMMA CUM LAUDE
            </span>
            <p className="text-[11px] font-mono text-slate-400">
              GPA 4.00
            </p>
          </div>
          <button 
            type="button"
            className="p-1 rounded-lg text-slate-400 hover:text-white transition-colors"
            aria-label={isExpanded ? 'Collapse pipeline' : 'Expand pipeline'}
          >
            {isExpanded ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
          </button>
        </div>
      </div>

      {/* Expanded Course Breakdown Drawer */}
      {isExpanded && (
        <div className="mt-4 pt-4 border-t border-white/10 animate-in fade-in duration-200">
          <div className="flex items-center justify-between mb-3 text-xs">
            <span className="font-semibold text-slate-300 flex items-center gap-1.5">
              <BookOpen className="w-3.5 h-3.5 text-[#75ACD8]" />
              Active Spring 2027 Curriculum Schedule
            </span>
            <span className="text-slate-400 font-mono text-[11px]">Liberty Online · 8-Week Terms</span>
          </div>

          <div className="space-y-2">
            {SPRING_PIPELINE_COURSES.map((course) => (
              <div 
                key={course.code}
                className="bg-black/30 rounded-xl p-2.5 sm:p-3 border border-white/5 flex items-center justify-between gap-3 text-xs"
              >
                <div className="flex items-center gap-2.5 min-w-0">
                  <div className="w-2 h-2 rounded-full bg-[#75ACD8] shrink-0" />
                  <div className="min-w-0">
                    <p className="font-semibold text-white truncate">
                      <span className="font-mono text-[#C6B386] mr-1.5">{course.code}</span>
                      {course.title}
                    </p>
                    <p className="text-[10px] text-slate-400 mt-0.5">
                      {course.term} · {course.category}
                    </p>
                  </div>
                </div>

                <div className="text-right shrink-0">
                  <span className="font-mono font-bold text-[#75ACD8] text-[11px] block">
                    {course.credits} Cr
                  </span>
                  <span className="text-[10px] text-emerald-400 font-medium">
                    {course.grade}
                  </span>
                </div>
              </div>
            ))}
          </div>

          {/* Final Summer Capstone Terminal Phase */}
          <div className="mt-3 p-3 bg-gradient-to-r from-black/40 via-blue-950/20 to-black/40 rounded-xl border border-white/5 text-xs flex items-center justify-between">
            <div className="flex items-center gap-2 text-slate-300">
              <Sparkles className="w-4 h-4 text-[#C6B386]" />
              <div>
                <span className="font-bold text-white">Final 9-Credit Capstone Phase:</span>
                <span className="text-slate-400 block text-[11px]">CJUS 490, CJUS 492, CJUS 499 (Summer 2027)</span>
              </div>
            </div>
            {onViewFullAudit && (
              <button
                onClick={onViewFullAudit}
                className="text-[#C6B386] hover:text-white font-semibold text-xs tracking-wide underline underline-offset-2 shrink-0 cursor-pointer"
              >
                View Full Audit
              </button>
            )}
          </div>
        </div>
      )}
    </div>
  );
};
