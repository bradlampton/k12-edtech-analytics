-- 05_school_adoption.sql
-- Purpose: Aggregates software adoption patterns and license utilization by campus.

CREATE OR REPLACE VIEW v_school_adoption_metrics AS
WITH student_engagement_summary AS (
    -- Pre-aggregate transactional logs per student to optimize calculation speeds
    SELECT 
        s.school_id,
        s.student_id,
        COUNT(e.event_id) AS total_logins,
        SUM(e.minutes_read) AS total_minutes,
        SUM(e.books_completed) AS total_books
    FROM dim_students s
    LEFT JOIN fact_engagement_events e ON s.student_id = e.student_id
    GROUP BY s.school_id, s.student_id
),
school_license_allocations AS (
    -- Simulates software license allocation targets vs actual active students
    SELECT 
        sch.school_id,
        sch.school_name,
        sch.funding_tier,
        COUNT(DISTINCT s.student_id) AS enrolled_students,
        -- Fictional contract tier metrics for portfolio analysis
        CASE 
            WHEN sch.funding_tier = 'Title I' THEN COUNT(DISTINCT s.student_id) * 1.10 -- Allocated buffer
            ELSE COUNT(DISTINCT s.student_id)
        END AS purchased_licenses
    FROM dim_schools sch
    LEFT JOIN dim_students s ON sch.school_id = s.school_id
    GROUP BY sch.school_id, sch.school_name, sch.funding_tier
)
SELECT 
    la.school_id,
    la.school_name,
    la.funding_tier,
    la.enrolled_students,
    ROUND(la.purchased_licenses::NUMERIC, 0) AS purchased_licenses,
    
    -- 1. Track license saturation metrics
    COUNT(DISTINCT es.student_id) FILTER (WHERE es.total_logins > 0) AS active_licensed_users,
    ROUND(
        (COUNT(DISTINCT es.student_id) FILTER (WHERE es.total_logins > 0) * 100.0) / 
        NULLIF(la.purchased_licenses, 0), 2
    ) AS license_utilization_rate,

    -- 2. Define highly engaged cohorts (e.g., reading over 120 total minutes over the term)
    COUNT(DISTINCT es.student_id) FILTER (WHERE es.total_minutes >= 120) AS heavy_users,
    
    -- 3. Calculate school-level usage footprints
    ROUND(AVG(es.total_minutes), 1) AS avg_minutes_per_student,
    ROUND(SUM(es.total_books), 0) AS total_books_read_by_campus,

    -- 4. Classify deployment risk categorization flags
    CASE 
        WHEN (COUNT(DISTINCT es.student_id) FILTER (WHERE es.total_logins > 0) * 100.0) / la.purchased_licenses >= 80 THEN 'High Adoption'
        WHEN (COUNT(DISTINCT es.student_id) FILTER (WHERE es.total_logins > 0) * 100.0) / la.purchased_licenses BETWEEN 50 AND 79 THEN 'Moderate Adoption'
        ELSE 'Underutilized Contract'
    END AS deployment_health_status

FROM school_license_allocations la
LEFT JOIN student_engagement_summary es ON la.school_id = es.school_id
GROUP BY la.school_id, la.school_name, la.funding_tier, la.enrolled_students, la.purchased_licenses;

-- Quick data integrity validation check
SELECT deployment_health_status, COUNT(*) AS school_count, AVG(license_utilization_rate) AS avg_utilization
FROM v_school_adoption_metrics
GROUP BY deployment_health_status;
