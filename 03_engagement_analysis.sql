
-- File: sql/03_engagement_analysis.sql
-- View 1: Daily Product Engagement
-- Grain: one row per activity date, school, and grade.

CREATE OR REPLACE VIEW vw_daily_engagement AS
SELECT
    ae.event_date::date AS activity_date,
    s.school_id,
    sc.school_name,
    s.grade_level,
    COUNT(DISTINCT ae.student_id) AS daily_active_students,
    COUNT(*) AS total_events,
    SUM(ae.minutes_spent) AS platform_activity_minutes,
    COUNT(*) FILTER (
        WHERE ae.event_type = 'article_completed'
    ) AS articles_completed,
    COUNT(*) FILTER (
        WHERE ae.event_type = 'quiz_completed'
    ) AS quizzes_completed
FROM activity_events ae
JOIN students s
    ON ae.student_id = s.student_id
JOIN schools sc
    ON s.school_id = sc.school_id
GROUP BY
    ae.event_date::date,
    s.school_id,
    sc.school_name,
    s.grade_level;


-- View 2: Student Engagement Summary
-- Grain: one row per student.

CREATE OR REPLACE VIEW vw_student_engagement AS
SELECT
    s.student_id,
    s.school_id,
    sc.school_name,
    s.grade_level,
    s.is_active,
    COUNT(ae.event_id) AS total_events,
    COUNT(DISTINCT ae.event_date::date) AS active_days,
    COALESCE(SUM(ae.minutes_spent), 0) AS platform_activity_minutes,
    COUNT(*) FILTER (
        WHERE ae.event_type = 'article_completed'
    ) AS articles_completed,
    COUNT(*) FILTER (
        WHERE ae.event_type = 'quiz_completed'
    ) AS quizzes_completed,
    MIN(ae.event_date::date) AS first_activity_date,
    MAX(ae.event_date::date) AS last_activity_date
FROM students s
JOIN schools sc
    ON s.school_id = sc.school_id
LEFT JOIN activity_events ae
    ON s.student_id = ae.student_id
GROUP BY
    s.student_id,
    s.school_id,
    sc.school_name,
    s.grade_level,
    s.is_active;
        
-- View 3: Weekly Active Students
-- Grain: one row per calendar week, school, and grade.

CREATE OR REPLACE VIEW vw_weekly_engagement AS
SELECT
    DATE_TRUNC('week', ae.event_date)::date AS week_start,
    s.school_id,
    sc.school_name,
    s.grade_level,
    COUNT(DISTINCT ae.student_id) AS weekly_active_students,
    COUNT(*) AS total_events,
    SUM(ae.minutes_spent) AS platform_activity_minutes
FROM activity_events ae
JOIN students s
    ON ae.student_id = s.student_id
JOIN schools sc
    ON s.school_id = sc.school_id
GROUP BY
    DATE_TRUNC('week', ae.event_date)::date,
    s.school_id,
    sc.school_name,
    s.grade_level;


-- View 4: Content Engagement
-- Grain: one row per content item and event type.

CREATE OR REPLACE VIEW vw_content_engagement AS
SELECT
    ae.content_id,
    ae.event_type,
    COUNT(*) AS total_events,
    COUNT(DISTINCT ae.student_id) AS unique_students,
    SUM(ae.minutes_spent) AS platform_activity_minutes
FROM activity_events ae
GROUP BY
    ae.content_id,
    ae.event_type;
