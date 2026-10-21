
import csv
import getpass
from pathlib import Path

import psycopg2
from psycopg2.extras import execute_values

PROJECT_DIR = Path(__file__).resolve().parent
DATA_DIR = PROJECT_DIR / "data"

# CSV filename -> PostgreSQL table and column order.
# Identity columns are omitted so PostgreSQL generates their values.
LOAD_CONFIG = [
    ("districts.csv", "districts",
     ["district_id", "district_name"]),
    ("schools.csv", "schools",
     ["school_id", "district_id", "school_name", "school_type", "state"]),
    ("students.csv", "students",
     ["student_id", "school_id", "grade_level", "enrollment_date", "is_active"]),
    ("teachers.csv", "teachers",
     ["teacher_id", "school_id", "subject", "hire_date"]),
    ("activity_events.csv", "activity_events",
     ["student_id", "event_date", "event_type", "minutes_spent", "content_id"]),
    ("assessments.csv", "assessments",
     ["student_id", "assessment_date", "assessment_type", "score", "skill_area"]),
    ("assignments.csv", "assignments",
     ["assignment_id", "teacher_id", "content_id", "assigned_date", "due_date"]),
    ("assignment_results.csv", "assignment_results",
     ["assignment_id", "student_id", "completed_date", "score"]),
]


def load_csv(cursor, filename, table, columns):
    path = DATA_DIR / filename

    if not path.exists():
        raise FileNotFoundError(f"Missing CSV file: {path}")

    with path.open("r", encoding="utf-8-sig", newline="") as file:
        reader = csv.DictReader(file)
        missing = set(columns) - set(reader.fieldnames or [])
        if missing:
            raise ValueError(f"{filename} is missing columns: {missing}")

        rows = [
            tuple(row[column] if row[column] != "" else None
                  for column in columns)
            for row in reader
        ]

    if not rows:
        print(f"{table}: 0 rows to load")
        return

    column_sql = ", ".join(f'"{column}"' for column in columns)
    insert_sql = (
        f'INSERT INTO "{table}" ({column_sql}) VALUES %s'
    )

    execute_values(cursor, insert_sql, rows, page_size=1000)
    print(f"{table}: loaded {len(rows):,} rows")


def main():
    password = getpass.getpass("PostgreSQL password for user postgres: ")

    connection = psycopg2.connect(
        host="localhost",
        port=5432,
        dbname="educational_analytics",
        user="postgres",
        password=password,
    )

    try:
        with connection:
            with connection.cursor() as cursor:
                # Prevent accidental duplicate loads into populated tables.
                cursor.execute("""
                    SELECT COUNT(*)
                    FROM districts
                """)
                if cursor.fetchone()[0] > 0:
                    raise RuntimeError(
                        "The database already contains district data. "
                        "Stopping to prevent duplicate imports."
                    )

                for filename, table, columns in LOAD_CONFIG:
                    load_csv(cursor, filename, table, columns)

        print("\nAll CSV files loaded successfully.")

    finally:
        connection.close()


if __name__ == "__main__":
    main()
