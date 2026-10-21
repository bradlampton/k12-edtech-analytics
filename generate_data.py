
from pathlib import Path
import random
import pandas as pd
from datetime import date, timedelta

# Reproducible synthetic data
random.seed(42)

PROJECT_DIR = Path(__file__).resolve().parent
DATA_DIR = PROJECT_DIR / "data"
DATA_DIR.mkdir(exist_ok=True)

START_DATE = date(2026, 1, 5)
DAYS = 90

def save_csv(name, rows):
    df = pd.DataFrame(rows)
    df.to_csv(DATA_DIR / f"{name}.csv", index=False)
    print(f"{name}.csv: {len(df):,} rows")
    return df

# 1. Districts
districts = [{
    "district_id": 1,
    "district_name": "Pine Valley Independent School District"
}]
save_csv("districts", districts)

# 2. Schools
schools = []
for school_id in range(1, 11):
    schools.append({
        "school_id": school_id,
        "district_id": 1,
        "school_name": f"Pine Valley School {school_id:02d}",
        "school_type": "Elementary" if school_id <= 6 else "Middle",
        "state": "TX"
    })
save_csv("schools", schools)

# 3. Students
students = []
for student_id in range(1, 1001):
    school_id = ((student_id - 1) // 100) + 1
    students.append({
        "student_id": student_id,
        "school_id": school_id,
        "grade_level": random.randint(3, 8),
        "enrollment_date": START_DATE.isoformat(),
        "is_active": True
    })
save_csv("students", students)

# 4. Teachers
subjects = ["Reading", "English Language Arts", "Writing"]
teachers = []
for teacher_id in range(1, 101):
    school_id = ((teacher_id - 1) // 10) + 1
    teachers.append({
        "teacher_id": teacher_id,
        "school_id": school_id,
        "subject": random.choice(subjects),
        "hire_date": (START_DATE - timedelta(days=random.randint(30, 2500))).isoformat()
    })
save_csv("teachers", teachers)

# 5. Reading platform activity
activity_events = []
event_id = 1

for student in students:
    # Not all students are active every day
    for day_number in range(DAYS):
        if random.random() < 0.32:
            event_date = START_DATE + timedelta(days=day_number)
            activity_events.append({
                "event_id": event_id,
                "student_id": student["student_id"],
                "event_date": (
                    f"{event_date.isoformat()} "
                    f"{random.randint(8, 15):02d}:"
                    f"{random.choice([0, 15, 30, 45]):02d}:00"
                ),
                "event_type": random.choice([
                    "article_opened",
                    "article_completed",
                    "quiz_started",
                    "quiz_completed"
                ]),
                "minutes_spent": random.randint(2, 25),
                "content_id": random.randint(1001, 1200)
            })
            event_id += 1

save_csv("activity_events", activity_events)

# 6. Beginning and ending assessments
assessments = []
assessment_id = 1

for student in students:
    baseline = random.uniform(35, 85)
    growth = random.uniform(-4, 15)

    for assessment_type, offset, score in [
        ("Beginning", 0, baseline),
        ("Ending", DAYS - 1, min(100, max(0, baseline + growth)))
    ]:
        assessment_date = START_DATE + timedelta(days=offset)
        assessments.append({
            "assessment_id": assessment_id,
            "student_id": student["student_id"],
            "assessment_date": assessment_date.isoformat(),
            "assessment_type": assessment_type,
            "score": round(score, 2),
            "skill_area": random.choice([
                "Reading Comprehension",
                "Vocabulary",
                "Main Idea",
                "Text Evidence"
            ])
        })
        assessment_id += 1

save_csv("assessments", assessments)

# 7. Assignments
assignments = []
for assignment_id in range(1, 101):
    teacher_id = random.randint(1, 100)
    assigned_date = START_DATE + timedelta(days=random.randint(0, DAYS - 15))
    assignments.append({
        "assignment_id": assignment_id,
        "teacher_id": teacher_id,
        "content_id": random.randint(1001, 1200),
        "assigned_date": assigned_date.isoformat(),
        "due_date": (assigned_date + timedelta(days=7)).isoformat()
    })

save_csv("assignments", assignments)

# 8. Assignment results
assignment_results = []
for assignment in assignments:
    teacher = teachers[assignment["teacher_id"] - 1]
    school_students = [
        s for s in students
        if s["school_id"] == teacher["school_id"]
    ]

    for student in school_students:
        # Model realistic incomplete assignments
        if random.random() < 0.78:
            completed_date = (
                date.fromisoformat(assignment["assigned_date"])
                + timedelta(days=random.randint(0, 10))
            )
            score = round(random.uniform(50, 100), 2)
        else:
            completed_date = None
            score = None

        assignment_results.append({
            "assignment_id": assignment["assignment_id"],
            "student_id": student["student_id"],
            "completed_date": (
                completed_date.isoformat() if completed_date else None
            ),
            "score": score
        })

save_csv("assignment_results", assignment_results)

print("\nAll synthetic CSV files generated successfully.")
print(f"Output folder: {DATA_DIR}")
