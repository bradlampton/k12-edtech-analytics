
-- 1. Check student distribution by school
SELECT
    sc.school_name,
    COUNT(st.student_id) AS student_count
FROM schools sc
LEFT JOIN students st
    ON sc.school_id = st.school_id
GROUP BY sc.school_id, sc.school_name
ORDER BY sc.school_name;

-- 2. Check platform activity by event type
SELECT
    event_type,
    COUNT(*) AS event_count,
    ROUND(AVG(minutes_spent), 2) AS avg_minutes
FROM activity_events
GROUP BY event_type
ORDER BY event_count DESC;

-- 3. Check assessment coverage
SELECT
    assessment_type,
    COUNT(*) AS assessment_count,
    ROUND(AVG(score), 2) AS average_score,
    MIN(score) AS lowest_score,
    MAX(score) AS highest_score
FROM assessments
GROUP BY assessment_type
ORDER BY assessment_type;

-- 4. Check assignment completion
SELECT
    COUNT(*) AS total_assignment_results,
    COUNT(completed_date) AS completed_assignments,
    COUNT(*) - COUNT(completed_date) AS incomplete_assignments,
    ROUND(
        100.0 * COUNT(completed_date) / NULLIF(COUNT(*), 0),
        2
    ) AS completion_rate_pct
FROM assignment_results;

-- 5. Check activity date range
SELECT
    MIN(event_date) AS first_activity,
    MAX(event_date) AS last_activity,
    COUNT(*) AS total_events
FROM activity_events;
