export type UserRole = 'super_admin' | 'admin' | 'school_owner' | 'teacher' | 'student' | 'parent' | 'staff' | 'government' | 'community';

export interface User {
  id: number;
  name: string;
  email: string;
  role: UserRole;
  school_id?: number;
  avatar?: string;
}

export interface School {
  id: number;
  name: string;
  city?: string;
  state?: string;
  phone?: string;
  email?: string;
  status: 'active' | 'inactive' | 'suspended';
  created_at: string;
}

export interface Class {
  id: number;
  school_id: number;
  name: string;
  section?: string;
  grade_level?: number;
  class_teacher_id?: number;
  status: 'active' | 'inactive';
}

export interface Subject {
  id: number;
  name: string;
  code?: string;
  teacher_id?: number;
  class_id?: number;
}

export interface Student {
  id: number;
  first_name: string;
  last_name: string;
  email: string;
  class_id?: number;
  admission_no?: string;
  class_name?: string;
}

export interface Attendance {
  id: number;
  student_id: number;
  class_id: number;
  date: string;
  status: 'present' | 'absent' | 'late' | 'excused';
}

export interface Grade {
  id: number;
  student_id: number;
  subject_id: number;
  marks_obtained: number;
  max_marks: number;
  title: string;
  assessment_type: string;
}

export interface Assignment {
  id: number;
  title: string;
  description?: string;
  class_id: number;
  subject_id: number;
  due_date: string;
  max_marks: number;
}

export interface Announcement {
  id: number;
  title: string;
  content: string;
  priority: 'low' | 'normal' | 'high' | 'urgent';
  created_at: string;
  author_name?: string;
}

export interface ApiResponse<T> {
  data?: T;
  error?: string;
  message?: string;
}
