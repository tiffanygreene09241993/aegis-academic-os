export interface CourseItem {
  code: string;
  title: string;
  credits: number;
  grade: string;
  term: string;
  status: 'completed' | 'in-progress' | 'planned';
  category: 'General Education' | 'Major Core' | 'Specialization' | 'Capstone';
}

export interface HonorSociety {
  id: string;
  name: string;
  abbreviation: string;
  discipline: string;
  status: string;
  inductedDate: string;
  gpaRequirement: string;
  description: string;
  regaliaCords: string;
}

export interface CountdownState {
  days: string;
  hours: string;
  minutes: string;
  seconds: string;
  totalMilliseconds: number;
}
