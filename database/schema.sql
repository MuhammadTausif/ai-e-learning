-- AI Smart School Management System
-- PostgreSQL Schema

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─── Schools ───────────────────────────────────────────────────────────────
CREATE TABLE schools (
    id           SERIAL PRIMARY KEY,
    name         VARCHAR(200) NOT NULL,
    address      TEXT,
    city         VARCHAR(100),
    state        VARCHAR(100),
    country      VARCHAR(100) DEFAULT 'Pakistan',
    phone        VARCHAR(30),
    email        VARCHAR(150),
    website      VARCHAR(200),
    logo         VARCHAR(300),
    status       VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active','inactive','suspended')),
    created_at   TIMESTAMP DEFAULT NOW()
);

-- ─── Users ─────────────────────────────────────────────────────────────────
CREATE TABLE users (
    id           SERIAL PRIMARY KEY,
    school_id    INTEGER REFERENCES schools(id) ON DELETE SET NULL,
    first_name   VARCHAR(100) NOT NULL,
    last_name    VARCHAR(100) NOT NULL,
    email        VARCHAR(150) UNIQUE NOT NULL,
    password     VARCHAR(255) NOT NULL,
    role         VARCHAR(30) NOT NULL CHECK (role IN ('super_admin','admin','school_owner','teacher','student','parent','staff','government','community')),
    phone        VARCHAR(30),
    address      TEXT,
    avatar       VARCHAR(300),
    gender       VARCHAR(10) CHECK (gender IN ('male','female','other')),
    date_of_birth DATE,
    status       VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active','inactive','suspended')),
    last_login   TIMESTAMP,
    reset_token  VARCHAR(100),
    reset_expiry TIMESTAMP,
    created_at   TIMESTAMP DEFAULT NOW(),
    updated_at   TIMESTAMP DEFAULT NOW()
);

-- ─── Classes ───────────────────────────────────────────────────────────────
CREATE TABLE classes (
    id           SERIAL PRIMARY KEY,
    school_id    INTEGER REFERENCES schools(id) ON DELETE CASCADE,
    name         VARCHAR(100) NOT NULL,
    section      VARCHAR(20),
    grade_level  INTEGER,
    room         VARCHAR(50),
    capacity     INTEGER DEFAULT 40,
    class_teacher_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    academic_year VARCHAR(20),
    status       VARCHAR(20) DEFAULT 'active',
    created_at   TIMESTAMP DEFAULT NOW()
);

-- ─── Subjects ──────────────────────────────────────────────────────────────
CREATE TABLE subjects (
    id           SERIAL PRIMARY KEY,
    school_id    INTEGER REFERENCES schools(id) ON DELETE CASCADE,
    class_id     INTEGER REFERENCES classes(id) ON DELETE CASCADE,
    name         VARCHAR(150) NOT NULL,
    code         VARCHAR(30),
    teacher_id   INTEGER REFERENCES users(id) ON DELETE SET NULL,
    credits      NUMERIC(4,1) DEFAULT 1.0,
    description  TEXT,
    status       VARCHAR(20) DEFAULT 'active',
    created_at   TIMESTAMP DEFAULT NOW()
);

-- ─── Student Profiles ──────────────────────────────────────────────────────
CREATE TABLE student_profiles (
    id              SERIAL PRIMARY KEY,
    user_id         INTEGER UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    class_id        INTEGER REFERENCES classes(id) ON DELETE SET NULL,
    admission_no    VARCHAR(50) UNIQUE,
    admission_date  DATE,
    roll_no         VARCHAR(30),
    blood_group     VARCHAR(10),
    emergency_contact VARCHAR(30),
    medical_notes   TEXT,
    created_at      TIMESTAMP DEFAULT NOW()
);

-- ─── Parent-Student Links ──────────────────────────────────────────────────
CREATE TABLE parent_student (
    id         SERIAL PRIMARY KEY,
    parent_id  INTEGER REFERENCES users(id) ON DELETE CASCADE,
    student_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    relation   VARCHAR(50) DEFAULT 'parent',
    UNIQUE(parent_id, student_id)
);

-- ─── Attendance ────────────────────────────────────────────────────────────
CREATE TABLE attendance (
    id           SERIAL PRIMARY KEY,
    student_id   INTEGER REFERENCES users(id) ON DELETE CASCADE,
    class_id     INTEGER REFERENCES classes(id) ON DELETE CASCADE,
    subject_id   INTEGER REFERENCES subjects(id) ON DELETE SET NULL,
    date         DATE NOT NULL,
    status       VARCHAR(20) NOT NULL CHECK (status IN ('present','absent','late','excused')),
    note         TEXT,
    marked_by    INTEGER REFERENCES users(id) ON DELETE SET NULL,
    created_at   TIMESTAMP DEFAULT NOW(),
    UNIQUE(student_id, class_id, date, subject_id)
);

-- ─── Grades / Marks ────────────────────────────────────────────────────────
CREATE TABLE grades (
    id              SERIAL PRIMARY KEY,
    student_id      INTEGER REFERENCES users(id) ON DELETE CASCADE,
    subject_id      INTEGER REFERENCES subjects(id) ON DELETE CASCADE,
    assessment_type VARCHAR(50) DEFAULT 'exam' CHECK (assessment_type IN ('exam','quiz','assignment','project','midterm','final','classwork')),
    title           VARCHAR(200),
    marks_obtained  NUMERIC(6,2),
    max_marks       NUMERIC(6,2) DEFAULT 100,
    term            VARCHAR(50),
    academic_year   VARCHAR(20),
    graded_by       INTEGER REFERENCES users(id) ON DELETE SET NULL,
    remarks         TEXT,
    created_at      TIMESTAMP DEFAULT NOW()
);

-- ─── Assignments ───────────────────────────────────────────────────────────
CREATE TABLE assignments (
    id           SERIAL PRIMARY KEY,
    subject_id   INTEGER REFERENCES subjects(id) ON DELETE CASCADE,
    class_id     INTEGER REFERENCES classes(id) ON DELETE CASCADE,
    title        VARCHAR(200) NOT NULL,
    description  TEXT,
    file_path    VARCHAR(300),
    due_date     TIMESTAMP,
    max_marks    NUMERIC(6,2) DEFAULT 100,
    created_by   INTEGER REFERENCES users(id) ON DELETE SET NULL,
    status       VARCHAR(20) DEFAULT 'active',
    created_at   TIMESTAMP DEFAULT NOW()
);

CREATE TABLE assignment_submissions (
    id              SERIAL PRIMARY KEY,
    assignment_id   INTEGER REFERENCES assignments(id) ON DELETE CASCADE,
    student_id      INTEGER REFERENCES users(id) ON DELETE CASCADE,
    file_path       VARCHAR(300),
    notes           TEXT,
    submitted_at    TIMESTAMP DEFAULT NOW(),
    marks_obtained  NUMERIC(6,2),
    feedback        TEXT,
    graded_by       INTEGER REFERENCES users(id) ON DELETE SET NULL,
    graded_at       TIMESTAMP,
    status          VARCHAR(20) DEFAULT 'submitted',
    UNIQUE(assignment_id, student_id)
);

-- ─── Timetable ─────────────────────────────────────────────────────────────
CREATE TABLE timetable (
    id           SERIAL PRIMARY KEY,
    class_id     INTEGER REFERENCES classes(id) ON DELETE CASCADE,
    subject_id   INTEGER REFERENCES subjects(id) ON DELETE CASCADE,
    teacher_id   INTEGER REFERENCES users(id) ON DELETE SET NULL,
    day_of_week  INTEGER NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
    start_time   TIME NOT NULL,
    end_time     TIME NOT NULL,
    room         VARCHAR(50),
    academic_year VARCHAR(20),
    created_at   TIMESTAMP DEFAULT NOW()
);

-- ─── Fee Management ────────────────────────────────────────────────────────
CREATE TABLE fee_types (
    id           SERIAL PRIMARY KEY,
    school_id    INTEGER REFERENCES schools(id) ON DELETE CASCADE,
    name         VARCHAR(150) NOT NULL,
    amount       NUMERIC(10,2) NOT NULL,
    frequency    VARCHAR(30) DEFAULT 'monthly' CHECK (frequency IN ('one_time','monthly','quarterly','yearly')),
    description  TEXT,
    status       VARCHAR(20) DEFAULT 'active'
);

CREATE TABLE fee_invoices (
    id           SERIAL PRIMARY KEY,
    student_id   INTEGER REFERENCES users(id) ON DELETE CASCADE,
    fee_type_id  INTEGER REFERENCES fee_types(id) ON DELETE SET NULL,
    amount       NUMERIC(10,2) NOT NULL,
    due_date     DATE,
    paid_date    DATE,
    payment_method VARCHAR(50),
    transaction_id VARCHAR(100),
    status       VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending','paid','overdue','waived')),
    notes        TEXT,
    created_by   INTEGER REFERENCES users(id) ON DELETE SET NULL,
    created_at   TIMESTAMP DEFAULT NOW()
);

-- ─── Announcements ─────────────────────────────────────────────────────────
CREATE TABLE announcements (
    id           SERIAL PRIMARY KEY,
    school_id    INTEGER REFERENCES schools(id) ON DELETE CASCADE,
    title        VARCHAR(300) NOT NULL,
    content      TEXT NOT NULL,
    target_roles TEXT[] DEFAULT ARRAY['all'],
    priority     VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('low','normal','high','urgent')),
    created_by   INTEGER REFERENCES users(id) ON DELETE SET NULL,
    publish_at   TIMESTAMP DEFAULT NOW(),
    expires_at   TIMESTAMP,
    status       VARCHAR(20) DEFAULT 'published',
    created_at   TIMESTAMP DEFAULT NOW()
);

-- ─── Community Posts ───────────────────────────────────────────────────────
CREATE TABLE community_posts (
    id           SERIAL PRIMARY KEY,
    school_id    INTEGER REFERENCES schools(id) ON DELETE SET NULL,
    title        VARCHAR(300) NOT NULL,
    content      TEXT NOT NULL,
    category     VARCHAR(100),
    author_id    INTEGER REFERENCES users(id) ON DELETE SET NULL,
    approved     BOOLEAN DEFAULT FALSE,
    approved_by  INTEGER REFERENCES users(id) ON DELETE SET NULL,
    views        INTEGER DEFAULT 0,
    created_at   TIMESTAMP DEFAULT NOW()
);

-- ─── Government Reports ────────────────────────────────────────────────────
CREATE TABLE govt_reports (
    id           SERIAL PRIMARY KEY,
    title        VARCHAR(300) NOT NULL,
    report_type  VARCHAR(100),
    school_id    INTEGER REFERENCES schools(id) ON DELETE CASCADE,
    generated_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
    data         JSONB,
    file_path    VARCHAR(300),
    period_from  DATE,
    period_to    DATE,
    status       VARCHAR(30) DEFAULT 'draft',
    created_at   TIMESTAMP DEFAULT NOW()
);

-- ─── AI Chat Logs (for future AI features) ─────────────────────────────────
CREATE TABLE ai_interactions (
    id           SERIAL PRIMARY KEY,
    user_id      INTEGER REFERENCES users(id) ON DELETE SET NULL,
    session_id   VARCHAR(100),
    role         VARCHAR(30),
    user_message TEXT,
    ai_response  TEXT,
    tokens_used  INTEGER,
    model        VARCHAR(100),
    created_at   TIMESTAMP DEFAULT NOW()
);

-- ─── Audit Log ─────────────────────────────────────────────────────────────
CREATE TABLE audit_log (
    id           SERIAL PRIMARY KEY,
    user_id      INTEGER REFERENCES users(id) ON DELETE SET NULL,
    action       VARCHAR(200) NOT NULL,
    table_name   VARCHAR(100),
    record_id    INTEGER,
    old_values   JSONB,
    new_values   JSONB,
    ip_address   VARCHAR(50),
    user_agent   TEXT,
    created_at   TIMESTAMP DEFAULT NOW()
);

-- ─── Indexes ───────────────────────────────────────────────────────────────
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_school ON users(school_id);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_attendance_student ON attendance(student_id, date);
CREATE INDEX idx_grades_student ON grades(student_id);
CREATE INDEX idx_announcements_school ON announcements(school_id);
CREATE INDEX idx_fees_student ON fee_invoices(student_id);

-- ─── Default Super Admin ───────────────────────────────────────────────────
-- Password: Admin@123 (bcrypt — update this before going live)
INSERT INTO users (first_name, last_name, email, password, role, status)
VALUES ('Super', 'Admin', 'admin@school.local',
        '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password
        'super_admin', 'active');
