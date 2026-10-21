-- 04_literacy_growth.sql
-- Purpose: Aggregates student assessment changes and buckets growth performance flags.

CREATE OR REPLACE VIEW v_student_literacy_growth AS
SELECT 
    s.student_id,
    s.school_id,
    sch.school_name,
    s.grade_level,
    a.baseline_score,
    a.mid_year_score,
    
    -- 1. Calculate raw scale score growth delta
    (a.mid_year_score - a.baseline_score) AS score_delta,
    
    -- 2. Define standard target targets based on grade bands
    CASE 
        WHEN s.grade_level <= 5 THEN 15  -- Elementary baseline growth target
        WHEN s.grade_level <= 8 THEN 10  -- Middle school baseline growth target
        ELSE 20                          -- High school baseline growth target
    END AS expected_growth_target,
    
    -- 3. Evaluate conditional tier logic matching student outcomes
    CASE 
        WHEN (a.mid_year_score - a.baseline_score) >= 15 THEN 'Exceeded Target'
        WHEN (a.mid_year_score - a.baseline_score) BETWEEN 5 AND 14 THEN 'Met Target'
        ELSE 'Needs Intervention'
    END AS growth_status,
    
    -- 4. Multi-tier comparative categorization flags
    CASE 
        WHEN a.mid_year_score < 300 THEN 'Below Grade Level'
        WHEN a.mid_year_score BETWEEN 300 AND 550 THEN 'At Grade Level'
        ELSE 'Above Grade Level'
    END AS mid_year_proficiency_tier

FROM dim_students s
JOIN dim_schools sch ON s.school_id = sch.school_id
JOIN fact_assessments a ON s.student_id = a.student_id;

-- Add a validation check query at the bottom to verify structural layout
SELECT growth_status, COUNT(*), ROUND(AVG(score_delta), 2) AS avg_delta
FROM v_student_literacy_growth
GROUP BY growth_status;
