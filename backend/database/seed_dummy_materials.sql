-- ====================================================================
-- Script Data Dummy Materi Lengkap Luma (Kurikulum SMA & Persiapan UTBK)
-- Berisi 4 Kursus & 8 Bab Pelajaran dengan video edukasi YouTube resmi
-- ====================================================================

-- 1. Kursus Matematika SMA
INSERT INTO courses (id, title, category_id, instructor_id, description, thumbnail_url, level, total_duration_seconds)
VALUES (
    'course-matematika-sma',
    'High School Calculus & Trigonometry',
    'cat-matematika',
    'a1111111-1111-1111-1111-111111111111',
    'Master algebraic limits, chain rule differential derivatives, and tangent lines with visual explanations from 3Blue1Brown and Khan Academy.',
    'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&w=800&q=80',
    'Grades 11 - 12',
    1575
) ON CONFLICT (id) DO UPDATE SET 
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    total_duration_seconds = EXCLUDED.total_duration_seconds;

INSERT INTO lessons (id, course_id, title, description, duration_seconds, video_url, order_index, is_preview)
VALUES 
(
    'ls-mat-01',
    'course-matematika-sma',
    'Calculus 1: Introduction to Limits',
    'Understanding function approaches, eliminating 0/0 indeterminate forms, and basic limit laws.',
    630,
    'https://www.youtube.com/watch?v=YNstP0ESndU',
    1,
    true
),
(
    'ls-mat-02',
    'course-matematika-sma',
    'Essence of Calculus: The Derivative Paradox',
    'Visualizing instantaneous rate of change, curve tangents, and derivatives by 3Blue1Brown.',
    945,
    'https://www.youtube.com/watch?v=9vKqVkMQHKk',
    2,
    false
) ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, video_url = EXCLUDED.video_url;

-- 2. Kursus Fisika SMA
INSERT INTO courses (id, title, category_id, instructor_id, description, thumbnail_url, level, total_duration_seconds)
VALUES (
    'course-fisika-sma',
    'Physics Mechanics: Newton''s Laws & Work-Energy',
    'cat-fisika',
    'a1111111-1111-1111-1111-111111111111',
    'Study particle motion dynamics, free-body force diagram analysis on inclined planes, and mechanical energy conservation with Crash Course Physics.',
    'https://images.unsplash.com/photo-1532094349884-543bc11b234d?auto=format&fit=crop&w=800&q=80',
    'Grades 10 - 11',
    1590
) ON CONFLICT (id) DO UPDATE SET 
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    total_duration_seconds = EXCLUDED.total_duration_seconds;

INSERT INTO lessons (id, course_id, title, description, duration_seconds, video_url, order_index, is_preview)
VALUES 
(
    'ls-fis-01',
    'course-fisika-sma',
    'Newton''s Laws of Motion: Crash Course Physics',
    'Analyzing inertia, F = ma, action-reaction forces, and free-body diagrams on inclined planes.',
    740,
    'https://www.youtube.com/watch?v=kKKM8Y-u7ds',
    1,
    true
),
(
    'ls-fis-02',
    'course-fisika-sma',
    'Work, Energy, & Power: Crash Course Physics',
    'Understanding kinetic and potential energy, the work-energy theorem, and mechanical conservation.',
    850,
    'https://www.youtube.com/watch?v=w4QFJb9a8vo',
    2,
    false
) ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, video_url = EXCLUDED.video_url;

-- 3. Kursus Biologi SMA
INSERT INTO courses (id, title, category_id, instructor_id, description, thumbnail_url, level, total_duration_seconds)
VALUES (
    'course-biologi-sma',
    'Genetics & Cell Biology: DNA to Protein Synthesis',
    'cat-biologi',
    'a1111111-1111-1111-1111-111111111111',
    'Deep dive into Mendelian genetics, double-helix DNA replication, transcription, and translation with 3D animation.',
    'https://images.unsplash.com/photo-1530497610245-94d3c16cda28?auto=format&fit=crop&w=800&q=80',
    'Grade 12',
    1495
) ON CONFLICT (id) DO UPDATE SET 
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    total_duration_seconds = EXCLUDED.total_duration_seconds;

INSERT INTO lessons (id, course_id, title, description, duration_seconds, video_url, order_index, is_preview)
VALUES 
(
    'ls-bio-01',
    'course-biologi-sma',
    'DNA Structure & Replication: Crash Course Biology',
    'Double helix structure, nucleotide bases, hydrogen bonding, and DNA helicase enzyme replication.',
    675,
    'https://www.youtube.com/watch?v=8kK2zwjRV0M',
    1,
    true
),
(
    'ls-bio-02',
    'course-biologi-sma',
    'From DNA to Protein: 3D Molecular Animation',
    'Detailed 3D visualization of transcription inside the nucleus and translation at the ribosome.',
    820,
    'https://www.youtube.com/watch?v=gG7uCskUOrA',
    2,
    false
) ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, video_url = EXCLUDED.video_url;

-- 4. Kursus Persiapan UTBK SNBT
INSERT INTO courses (id, title, category_id, instructor_id, description, thumbnail_url, level, total_duration_seconds)
VALUES (
    'course-utbk-mastery',
    'College Exam Prep: Quantitative Reasoning Mastery',
    'cat-utbk',
    'a1111111-1111-1111-1111-111111111111',
    'Speed strategies for General Reasoning, Quantitative Knowledge, and Reading Comprehension.',
    'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?auto=format&fit=crop&w=800&q=80',
    'Grade 12 & Gap Year',
    1820
) ON CONFLICT (id) DO UPDATE SET 
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    total_duration_seconds = EXCLUDED.total_duration_seconds;

INSERT INTO lessons (id, course_id, title, description, duration_seconds, video_url, order_index, is_preview)
VALUES 
(
    'ls-utbk-01',
    'course-utbk-mastery',
    'Integration & Fundamental Theorem of Calculus',
    'Connecting areas under curves to anti-derivatives and high-yield math exam problem solving.',
    920,
    'https://www.youtube.com/watch?v=rfG8ce4nNh0',
    1,
    true
),
(
    'ls-utbk-02',
    'course-utbk-mastery',
    'Neural Networks & Mathematical Logic by 3Blue1Brown',
    'Logical reasoning, weight parameters, matrix operations, and abstract thinking for college prep.',
    900,
    'https://www.youtube.com/watch?v=aircAruvnKk',
    2,
    false
) ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, video_url = EXCLUDED.video_url;
