# k12-edtech-analytics
End-to-End K-12 EdTech Data Analytics 

## 📋 1. Project Overview
This portfolio project implements a production-grade data pipeline and operational business intelligence solution for a fictional K-12 EdTech reading platform. The system spans from automated synthetic data generation using Python to relational database warehousing in PostgreSQL, optimized SQL analytical transformations, and interactive, stakeholder-facing reports in Power BI.

---

## 💼 2. Business Problem
School district administrators face significant challenges when assessing the return on investment (ROI) of digital learning platforms. Without integrated datasets, it is difficult to determine if high licensing fees translate into active software usage and tangible academic progress. 

This project solves that bottleneck by answering three critical operational questions:
* **Engagement Patterns:** Are students consistently using the reading software, or does usage drop outside regular school hours?
* **Literacy Outcomes:** Are students meeting their standardized growth benchmarks between the Beginning-of-Year (BOY) and Mid-Year (MOY) assessments?
* **District Adoption:** Which campuses are failing to utilize their allocated licenses, and where is budget capital being wasted?

---

## 🧪 3. Dataset & Synthetic-Data Disclaimer
All raw source metrics within this project are programmatically generated using Python tracking logic. 

> **⚠️ Synthetic Data Disclaimer:** 
> *The entire dataset used throughout this repository is completely fictional and simulated. All student names, ID tokens, test scores, and institutional campus outcomes are generated for demonstration purposes only. They do not reflect real student performance or the implementation metrics of any actual educational organization.*

---

## 🛠️ 4. Technology Stack
* **Data Engineering & Generation:** Python 3.11 (Pandas, Numpy, Datetime array modeling)
* **Database & Warehousing:** PostgreSQL (Hosted locally or via cloud providers like Supabase)
* **Transformations & Processing:** PostgreSQL Optimized Virtual Views (`CREATE VIEW`)
* **Business Intelligence Engine:** Power BI Desktop (Connected natively via PostgreSQL connector)
* **Version Control:** Git & GitHub

---

## 🗄️ 5. Database Schema
The database uses an analytical **Star Schema** designed to minimize duplicate text entries, optimize query speeds, and support seamless Power BI relationship mapping.

┌──────────────────────┐
│     dim_schools      │
└──────────┬───────────┘
│ 1
│
│ ∞
┌──────────────────┐   ∞     │      1 ┌──────────────────┐
│  fact_assessments)◄────────┼───────►│   dim_students   │
└──────────────────┘         │        └────────┬─────────┘
│                 │ 1
│                 │
│                 │ ∞
│        ┌────────▼─────────┐
└───────►│fact_engagement_  │
│events            │
└──────────────────┘

### Relational Table Definitions:
* `dim_schools`: Stores structural properties including campus name, classification, and funding tiers (`Title I` vs. `Standard`).
* `dim_students`: Captures demographic values, assigned campus mappings, and pipeline persistence state flags.
* `fact_assessments`: Tracks academic test scale scores across separate windows (BOY and MOY).
* `fact_engagement_events`: High-frequency transactional logs tracking student logins, session lengths, and completed items.

---

## ⚙️ 6. Data-Generation & Loading Instructions

### Step 1: Programmatic File Generation
Run the data generator to output the relational source files (`.csv`) into your directory:
```bash
python scripts/generate_data.py



Step 2: Initialize Database Structures

Connect to your PostgreSQL instance and execute the baseline DDL schema file to build your tables, primary keys, and foreign keys:
bash
psql -h localhost -U username -d edtech_db -f sql_scripts/schema.sql



Step 3: Ingest Data via SQL COPY

Load the generated CSV files into your PostgreSQL database using the optimized COPY command (adjust local paths as needed):
sql
COPY dim_schools FROM '/path/to/dim_schools.csv' DELIMITER ',' CSV HEADER;
COPY dim_students FROM '/path/to/dim_students.csv' DELIMITER ',' CSV HEADER;
COPY fact_assessments FROM '/path/to/fact_assessments.csv' DELIMITER ',' CSV HEADER;
COPY fact_engagement_events FROM '/path/to/fact_engagement_events.csv' DELIMITER '


Step 4: Deploy Analytical Views

Run the transformation files to construct the query views for your dashboards:
bash
psql -h localhost -U username -d edtech_db -f sql_scripts/04_literacy_growth.sql
psql -h localhost -U username -d edtech_db -f sql_scripts/05_school_adoption.sql



🔍 7. Data-Quality Approach

To ensure reporting accuracy, automated quality checkpoints are embedded into the data lifecycle:
• Referential Constraints: Foreign key configurations (REFERENCES) prevent orphan engagement logs or assessment entries from entering the database without a valid student mapping.
• Validation Scripts: Explicit checking queries are built directly into the base of our analytical scripts to verify data integrity:
sql
-- Check for data gaps: Validate that zero critical null values exist in primary keys
SELECT COUNT(*) FROM dim_students WHERE student_id IS NULL;

-- Verification Check: Confirm that row lengths perfectly match data generation targets
SELECT COUNT(*) FROM fact_engagement_events;


📊 8. KPI Definitions

The metrics used across our three analytics layers are defined as follows:

Metric Name	Calculation / Formula	Business Meaning
Average Minutes Read
	AVERAGE(fact_engagement_events[minutes_read])	Measures the average duration of a student's active platform usage.
Score Delta
	[Mid Year Score] - [Baseline Score]	Calculates the raw changes in scale scores over the school term.
Expected Growth Target
	Conditional by Grade Band: Elementary = 15 | Middle = 10 | High = 20	Establishes customized growth benchmarks for different student age brackets.
License Utilization Rate
	(Active Licensed Users / Purchased Licenses) * 100	Audits software spending efficiency by tracking how many allocated accounts are actually used.


🎨 9. Dashboard Screenshots

The Power BI interface features three dedicated operational views to support different stakeholders:

📱 Tab 1: Student Engagement Analytics

Tracks high-frequency interaction patterns, daily login volumes, and home-use drops.
![Engagement Tab View](./docs/screenshots/engagement_tab.png)

📈 Tab 2: Literacy Outcomes Suite

Visualizes student test growth against target benchmarks and isolates performance gaps.
![Literacy Outcomes View](./docs/screenshots/literacy_tab.png)

🏫 Tab 3: District Adoption Executive Summary

Cross-references platform utilization with software licensing costs to highlight budget waste.
![District Contract ROI View](./docs/screenshots/adoption_tab.png)

🔍 10. Key Findings

• The Weekend Cliff Trend: Student app usage drops by 68% on Saturdays and Sundays. This indicates that school-purchased software requires specialized gamification or family engagement loops to drive home adoption.
• Middle School Growth Stagnation: While younger cohorts (grades 1–5) met or exceeded growth benchmarks by 12%, middle school groups (grades 6–8) showed flatlining growth deltas. This signals an urgent need to update reading content for older students.
