-- Clean setup loop for structural testing
DROP TABLE IF EXISTS fact_engagement_events CASCADE;
DROP TABLE IF EXISTS fact_assessments CASCADE;
DROP TABLE IF EXISTS dim_students CASCADE;
DROP TABLE IF EXISTS dim_schools CASCADE;

-- 1. Dimension Tables
CREATE TABLE dim_schools (
    school_id VARCHAR(10) PRIMARY KEY,
    school_name VARCHAR(100) NOT NULL,
    funding_tier VARCHAR(20) NOT NULL
);

CREATE TABLE dim_students (
    student_id VARCHAR(10) PRIMARY KEY,
    school_id VARCHAR(10) REFERENCES dim_schools(school_id) ON DELETE CASCADE,
    grade_level INT NOT NULL,
    gender VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE
);

-- 2. Fact Tables
CREATE TABLE fact_assessments (
    student_id VARCHAR(10) PRIMARY KEY REFERENCES dim_students(student_id) ON DELETE CASCADE,
    baseline_score INT NOT NULL,
    mid_year_score INT NOT NULL
);

CREATE TABLE fact_engagement_events (
    event_id VARCHAR(12) PRIMARY KEY,
    student_id VARCHAR(10) REFERENCES dim_students(student_id) ON DELETE CASCADE,
    timestamp TIMESTAMP NOT NULL,
    minutes_read INT NOT NULL,
    books_completed INT DEFAULT 0
);

-- Indexes to optimize Power BI aggregation speeds
CREATE INDEX idx_events_student ON fact_engagement_events(student_id);
CREATE INDEX idx_events_timestamp ON fact_engagement_events(timestamp);
