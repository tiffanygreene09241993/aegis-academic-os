import { CourseItem, HonorSociety } from '../types/academic';

export const TARGET_GRADUATION_DATE = 'August 20, 2027 00:00:00';

export const ACADEMIC_PROFILE = {
  institution: 'Liberty University',
  degree: 'Bachelor of Science in Criminal Justice (B.S.-CJ)',
  specialization: 'Homeland Security & Justice Administration',
  targetDateStr: 'August 20, 2027',
  cumulativeGpa: '4.00',
  academicStanding: 'Summa Cum Laude',
  totalCredits: 121,
  completedCredits: 94,
  inProgressCredits: 18,
  remainingCredits: 9,
  completionPercentage: 78,
  graduationTerm: 'Summer/Fall 2027',
};

export const SPRING_PIPELINE_COURSES: CourseItem[] = [
  {
    code: 'CJUS 300',
    title: 'Administration of Justice Systems',
    credits: 3,
    grade: 'A (Projected)',
    term: 'Spring 2027 · Sub-Term B',
    status: 'in-progress',
    category: 'Major Core',
  },
  {
    code: 'CJUS 340',
    title: 'Criminology & Behavioral Analysis',
    credits: 3,
    grade: 'A (Projected)',
    term: 'Spring 2027 · Sub-Term B',
    status: 'in-progress',
    category: 'Major Core',
  },
  {
    code: 'CJUS 380',
    title: 'Introduction to Homeland Security',
    credits: 3,
    grade: 'A (Projected)',
    term: 'Spring 2027 · Sub-Term B',
    status: 'in-progress',
    category: 'Specialization',
  },
  {
    code: 'CJUS 400',
    title: 'Criminal Law & Statutory Procedure',
    credits: 3,
    grade: 'A (Projected)',
    term: 'Spring 2027 · Sub-Term D',
    status: 'in-progress',
    category: 'Major Core',
  },
  {
    code: 'CJUS 410',
    title: 'Constitutional Criminal Procedure',
    credits: 3,
    grade: 'A (Projected)',
    term: 'Spring 2027 · Sub-Term D',
    status: 'in-progress',
    category: 'Major Core',
  },
  {
    code: 'GOVT 480',
    title: 'Terrorism & National Security Policy',
    credits: 3,
    grade: 'A (Projected)',
    term: 'Spring 2027 · Sub-Term D',
    status: 'in-progress',
    category: 'Specialization',
  },
];

export const REMAINING_COURSES: CourseItem[] = [
  {
    code: 'CJUS 490',
    title: 'Criminal Justice Senior Seminar',
    credits: 3,
    grade: 'Scheduled',
    term: 'Summer 2027 · Sub-Term A',
    status: 'planned',
    category: 'Capstone',
  },
  {
    code: 'CJUS 492',
    title: 'Advanced Research in Justice Systems',
    credits: 3,
    grade: 'Scheduled',
    term: 'Summer 2027 · Sub-Term B',
    status: 'planned',
    category: 'Capstone',
  },
  {
    code: 'CJUS 499',
    title: 'Criminal Justice Senior Honors Practicum',
    credits: 3,
    grade: 'Scheduled',
    term: 'Summer 2027 · Sub-Term D',
    status: 'planned',
    category: 'Capstone',
  },
];

export const COMPLETED_HIGHLIGHTS: CourseItem[] = [
  { code: 'MATH 201', title: 'Introduction to Probability & Statistics', credits: 3, grade: 'A (4.0)', term: 'Fall 2025', status: 'completed', category: 'General Education' },
  { code: 'CJUS 200', title: 'Introduction to Criminal Justice', credits: 3, grade: 'A (4.0)', term: 'Spring 2025', status: 'completed', category: 'Major Core' },
  { code: 'CJUS 230', title: 'Criminal Law Fundamentals', credits: 3, grade: 'A (4.0)', term: 'Fall 2025', status: 'completed', category: 'Major Core' },
  { code: 'CJUS 280', title: 'Judicial Process in America', credits: 3, grade: 'A (4.0)', term: 'Spring 2026', status: 'completed', category: 'Major Core' },
  { code: 'CJUS 320', title: 'Corrections & Rehabilitation Policy', credits: 3, grade: 'A (4.0)', term: 'Fall 2026', status: 'completed', category: 'Major Core' },
  { code: 'PLST 200', title: 'Introduction to Legal Studies', credits: 3, grade: 'A (4.0)', term: 'Spring 2026', status: 'completed', category: 'Specialization' },
  { code: 'GOVT 220', title: 'American Government & Public Law', credits: 3, grade: 'A (4.0)', term: 'Fall 2025', status: 'completed', category: 'Major Core' },
  { code: 'CJUS 350', title: 'Criminal Investigations & Forensics', credits: 3, grade: 'A (4.0)', term: 'Fall 2026', status: 'completed', category: 'Major Core' },
];

export const HONOR_SOCIETIES: HonorSociety[] = [
  {
    id: 'onl',
    name: 'Omega Nu Lambda National Honor Society',
    abbreviation: 'ONL · Alpha Chapter',
    discipline: 'Collegiate Academic Excellence',
    status: 'Inducted & Verified',
    inductedDate: 'Spring 2026',
    gpaRequirement: 'Minimum 3.80 cumulative GPA',
    description: 'Recognizes academic achievement and provides community for outstanding undergraduate scholars demonstrating collegiate distinction.',
    regaliaCords: 'Double Navy Blue & Silver Honor Cords with Onyx Medallion',
  },
  {
    id: 'sword-shield',
    name: 'The Sword & Shield National Honor Society',
    abbreviation: 'Omicron Sigma Sigma',
    discipline: 'Homeland Security, Intelligence & Criminal Justice',
    status: 'Charter Member · Verified',
    inductedDate: 'Fall 2026',
    gpaRequirement: 'Top 10% class rank with 3.50+ disciplinary GPA (Maintained 4.00)',
    description: 'The sole national academic honor society dedicated exclusively to Homeland Security, Intelligence, Emergency Management, and Criminal Justice disciplines.',
    regaliaCords: 'Intertwined Royal Blue & Metallic Gold Cords with Shield Crest',
  },
];

export const REGALIA_INVENTORY = [
  {
    item: 'Champagne-Gold Custom Mortarboard',
    distinction: 'Commencement Milestone Emblem',
    status: 'Ready for Conferral',
    tassel: 'Left-turn ceremonial tassel with 2027 Charm',
    detail: 'Rich champagne-gold satin finish with precision gold embroidery',
  },
  {
    item: 'Liberty University Crimson & White Stole',
    distinction: 'Institutional Baccalaureate Regalia',
    status: 'Allocated',
    tassel: 'Official Liberty flame insignia embroidered in gold bullion',
    detail: 'Flames of Truth emblem with collegiate silk-satin drape',
  },
  {
    item: 'Summa Cum Laude Honors Medallion',
    distinction: 'Highest Institutional Academic Honors',
    status: 'Certified (GPA 4.00)',
    tassel: 'Ribbon drape in navy and champagne gold',
    detail: 'Heavy brass alloy medallion embossed with University seal',
  },
  {
    item: 'Dual Honor Society Distinction Cords',
    distinction: 'Omega Nu Lambda & Sword & Shield',
    status: 'Awarded & Verified',
    tassel: 'Twin tassels with enameled society emblems',
    detail: 'Woven royal blue, navy, silver, and gold ceremonial honors braids',
  },
];
