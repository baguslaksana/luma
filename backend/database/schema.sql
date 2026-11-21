-- ====================================================================
-- PostgreSQL Database Schema for Luma Simple E-Learning Platform
-- Supports Role-Based Access Control (RBAC): Siswa & Pengajar/Guru
-- ====================================================================

-- 1. Create Role Enum Type
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE user_role AS ENUM ('siswa', 'pengajar');
    END IF;
END$$;

-- 2. Users Table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role user_role NOT NULL DEFAULT 'siswa',
    avatar_url TEXT,
    bio TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Categories Table
CREATE TABLE IF NOT EXISTS categories (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Courses Table
CREATE TABLE IF NOT EXISTS courses (
    id VARCHAR(100) PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    category_id VARCHAR(50) REFERENCES categories(id) ON DELETE SET NULL,
    instructor_id UUID REFERENCES users(id) ON DELETE CASCADE,
    description TEXT,
    thumbnail_url TEXT,
    level VARCHAR(50) DEFAULT 'Semua Jenjang',
    total_duration_seconds INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Lessons Table
CREATE TABLE IF NOT EXISTS lessons (
    id VARCHAR(100) PRIMARY KEY,
    course_id VARCHAR(100) REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    duration_seconds INT NOT NULL DEFAULT 0,
    video_url TEXT NOT NULL,
    order_index INT NOT NULL DEFAULT 1,
    is_preview BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Student Enrollments Table (Siswa)
CREATE TABLE IF NOT EXISTS enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID REFERENCES users(id) ON DELETE CASCADE,
    course_id VARCHAR(100) REFERENCES courses(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT unique_student_course UNIQUE (student_id, course_id)
);

-- 7. Lesson Progress Table (Siswa)
CREATE TABLE IF NOT EXISTS lesson_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID REFERENCES users(id) ON DELETE CASCADE,
    lesson_id VARCHAR(100) REFERENCES lessons(id) ON DELETE CASCADE,
    is_completed BOOLEAN DEFAULT false,
    last_position_seconds INT DEFAULT 0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_student_lesson UNIQUE (student_id, lesson_id)
);

-- ====================================================================
-- Initial Seed Data: Pengajar, Siswa, & SMA Curriculum Courses
-- ====================================================================

-- 1. Insert Pengajar (Guru SMA)
INSERT INTO users (id, full_name, email, password_hash, role, bio)
VALUES 
(
    'a1111111-1111-1111-1111-111111111111',
    'Drs. Bambang Sudarsono, M.Pd.',
    'pengajar@luma.com',
    'pengajar',
    'pengajar',
    'Guru senior matematika SMA 15+ tahun mengajar kalkulus dan trigonometri.'
)
ON CONFLICT (email) DO NOTHING;

-- 2. Insert Siswa (Student SMA)
INSERT INTO users (id, full_name, email, password_hash, role, bio)
VALUES 
(
    'b2222222-2222-2222-2222-222222222222',
    'ARI BAGUS',
    'siswa@luma.com',
    'siswa',
    'siswa',
    'Siswa SMA Kelas 12 fokus persiapan UTBK & SNBT 2026.'
)
ON CONFLICT (email) DO NOTHING;

-- 3. Insert Categories
INSERT INTO categories (id, name, slug)
VALUES
    ('cat-matematika', 'Matematika', 'matematika'),
    ('cat-fisika', 'Fisika', 'fisika'),
    ('cat-biologi', 'Biologi', 'biologi'),
    ('cat-kimia', 'Kimia', 'kimia'),
    ('cat-bahasa', 'Bahasa & Literasi', 'bahasa'),
    ('cat-utbk', 'Persiapan UTBK', 'utbk')
ON CONFLICT (id) DO NOTHING;

-- 4. Insert Sample Courses
INSERT INTO courses (id, title, category_id, instructor_id, description, thumbnail_url, level, total_duration_seconds)
VALUES 
(
    'course-matematika-sma',
    'Kalkulus & Trigonometri SMA',
    'cat-matematika',
    'a1111111-1111-1111-1111-111111111111',
    'Kupas tuntas konsep limit, turunan diferensial, dan integral kurva dengan visualisasi praktis.',
    'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&w=800&q=80',
    'Kelas 11 - 12',
    30600
),
(
    'course-utbk-mastery',
    'Intensif UTBK & SNBT 2026',
    'cat-utbk',
    'a1111111-1111-1111-1111-111111111111',
    'Kuasai materi TPS dan TKA bersama tutor terbaik untuk lolos PTN impian.',
    'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?auto=format&fit=crop&w=800&q=80',
    'Kelas 12 & Gap Year',
    43200
)
ON CONFLICT (id) DO NOTHING;

-- 5. Insert Lessons
INSERT INTO lessons (id, course_id, title, description, duration_seconds, video_url, order_index, is_preview)
VALUES
(
    'ls-mat-01',
    'course-matematika-sma',
    'Konsep Limit Fungsi Aljabar & Tak Hingga',
    'Memahami sifat limit fungsi aljabar dan faktorisasi rasional.',
    632,
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    1,
    true
),
(
    'ls-mat-02',
    'course-matematika-sma',
    'Aturan Turunan & Teorema L''Hopital',
    'Menghitung turunan perkalian dan aturan rantai diferensial.',
    932,
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    2,
    true
)
ON CONFLICT (id) DO NOTHING;
