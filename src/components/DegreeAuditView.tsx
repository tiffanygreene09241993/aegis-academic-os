import React, { useState } from 'react';
import { SPRING_PIPELINE_COURSES, REMAINING_COURSES, COMPLETED_HIGHLIGHTS, ACADEMIC_PROFILE } from '../data/degreeData';
import { CourseItem } from '../types/academic';
import { CheckCircle2, Clock, BookOpen, AlertCircle, Sparkles } from 'lucide-react';

export const DegreeAuditView: React.FC = () => {
  const [filter, setFilter] = useState<'all' | 'in-progress' | 'planned' | 'completed'>('all');

  const allCourses: CourseItem[] = [
    ...COMPLETED_HIGHLIGHTS,
    ...SPRING_PIPELINE_COURSES,
    ...REMAINING_COURSES,
  ];

  const filteredCourses = allCourses.filter((course) => {
    if (filter === 'all') return true;
    return course.status === filter;
  });

  return (
    <div className="space-y-6">
      {/* Header Telemetry Strip */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <div className="glass-panel rounded-2xl p-4 text-left">
          <p className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">Total Degree Goal</p>
          <p className="text-2xl font-black font-mono text-white mt-1">121 <span className="text-xs font-normal text-slate-400">Credits</span></p>
          <p className="text-[10px] text-[#75ACD8] mt-0.5">Liberty Univ · BS-CJ</p>
        </div>

        <div className="glass-panel rounded-2xl p-4 text-left">
          <p className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">Completed & Verified</p>
          <p className="text-2xl font-black font-mono text-emerald-400 mt-1">94 <span className="text-xs font-normal text-slate-400">Credits</span></p>
          <p className="text-[10px] text-emerald-400/80 mt-0.5">78% Degree Requirement</p>
        </div>

        <div className="glass-panel rounded-2xl p-4 text-left">
          <p className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">Spring 2027 Pipeline</p>
          <p className="text-2xl font-black font-mono text-[#C6B386] mt-1">18 <span className="text-xs font-normal text-slate-400">Credits</span></p>
          <p className="text-[10px] text-[#C6B386]/80 mt-0.5">Active Enrollment</p>
        </div>

        <div className="glass-panel rounded-2xl p-4 text-left">
          <p className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">Final Capstone Phase</p>
          <p className="text-2xl font-black font-mono text-[#75ACD8] mt-1">9 <span className="text-xs font-normal text-slate-400">Credits</span></p>
          <p className="text-[10px] text-[#75ACD8]/80 mt-0.5">Summer '27 Terminal</p>
        </div>
      </div>

      {/* Curriculum Filter Tabs */}
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div>
          <h2 className="text-lg font-bold text-white tracking-wide">
            Degree Audit & Academic Roadmap
          </h2>
          <p className="text-xs text-slate-400">
            Bachelor of Science in Criminal Justice · Official Curricular Ledger
          </p>
        </div>

        {/* Filter buttons */}
        <div className="flex items-center gap-1.5 p-1 bg-black/40 rounded-xl border border-white/10">
          <button
            onClick={() => setFilter('all')}
            className={`px-3 py-1.5 text-xs font-medium rounded-lg transition-colors cursor-pointer ${
              filter === 'all' ? 'bg-[#0A254E] text-[#C6B386] font-bold shadow-sm' : 'text-slate-400 hover:text-white'
            }`}
          >
            All Courses ({allCourses.length})
          </button>
          <button
            onClick={() => setFilter('in-progress')}
            className={`px-3 py-1.5 text-xs font-medium rounded-lg transition-colors cursor-pointer ${
              filter === 'in-progress' ? 'bg-[#0A254E] text-[#C6B386] font-bold shadow-sm' : 'text-slate-400 hover:text-white'
            }`}
          >
            Spring '27 Active (6)
          </button>
          <button
            onClick={() => setFilter('planned')}
            className={`px-3 py-1.5 text-xs font-medium rounded-lg transition-colors cursor-pointer ${
              filter === 'planned' ? 'bg-[#0A254E] text-[#C6B386] font-bold shadow-sm' : 'text-slate-400 hover:text-white'
            }`}
          >
            Capstone (3)
          </button>
          <button
            onClick={() => setFilter('completed')}
            className={`px-3 py-1.5 text-xs font-medium rounded-lg transition-colors cursor-pointer ${
              filter === 'completed' ? 'bg-[#0A254E] text-[#C6B386] font-bold shadow-sm' : 'text-slate-400 hover:text-white'
            }`}
          >
            Completed Highlights
          </button>
        </div>
      </div>

      {/* Course Ledger Table */}
      <div className="glass-panel rounded-2xl overflow-hidden border border-white/10">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead>
              <tr className="bg-black/40 border-b border-white/10 text-slate-400 font-mono uppercase tracking-wider">
                <th className="py-3 px-4">Status</th>
                <th className="py-3 px-4">Course Code</th>
                <th className="py-3 px-4">Title & Discipline</th>
                <th className="py-3 px-4">Category</th>
                <th className="py-3 px-4">Term</th>
                <th className="py-3 px-4 text-right">Credits</th>
                <th className="py-3 px-4 text-right">Grade / Standing</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-white/5">
              {filteredCourses.map((course) => (
                <tr key={course.code} className="hover:bg-white/[0.02] transition-colors">
                  <td className="py-3.5 px-4 whitespace-nowrap">
                    {course.status === 'completed' && (
                      <span className="flex items-center gap-1.5 text-emerald-400 font-medium">
                        <CheckCircle2 className="w-4 h-4" />
                        <span>Completed</span>
                      </span>
                    )}
                    {course.status === 'in-progress' && (
                      <span className="flex items-center gap-1.5 text-[#C6B386] font-medium">
                        <Clock className="w-4 h-4" />
                        <span>In Progress</span>
                      </span>
                    )}
                    {course.status === 'planned' && (
                      <span className="flex items-center gap-1.5 text-[#75ACD8] font-medium">
                        <Sparkles className="w-4 h-4" />
                        <span>Scheduled</span>
                      </span>
                    )}
                  </td>
                  <td className="py-3.5 px-4 font-mono font-bold text-white whitespace-nowrap">
                    {course.code}
                  </td>
                  <td className="py-3.5 px-4 font-medium text-slate-200">
                    {course.title}
                  </td>
                  <td className="py-3.5 px-4 text-slate-400 whitespace-nowrap">
                    {course.category}
                  </td>
                  <td className="py-3.5 px-4 text-slate-400 font-mono text-[11px] whitespace-nowrap">
                    {course.term}
                  </td>
                  <td className="py-3.5 px-4 font-mono text-right font-bold text-white whitespace-nowrap">
                    {course.credits}
                  </td>
                  <td className="py-3.5 px-4 font-mono text-right font-bold text-[#C6B386] whitespace-nowrap">
                    {course.grade}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Academic Policy Citation Note */}
      <div className="p-4 rounded-xl bg-black/30 border border-white/5 flex items-start gap-3 text-xs text-slate-400">
        <AlertCircle className="w-4 h-4 text-[#75ACD8] shrink-0 mt-0.5" />
        <div>
          <span className="font-semibold text-slate-200">Institutional Residency & Honors Rules:</span> Liberty University requires a minimum of 30 institutional credit hours and a cumulative 3.90+ GPA for Summa Cum Laude distinction at degree conferral. Current student GPA is 4.00, satisfying all institutional honors prerequisites.
        </div>
      </div>
    </div>
  );
};
