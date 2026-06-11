# SIS Database Schema

## Overview

This document describes the database schema used by the Student Information System (SIS).

---

# faculties

Stores available faculties.

| Column | Type   | Description  |
| ------ | ------ | ------------ |
| id     | bigint | Primary Key  |
| name   | text   | Faculty Name |
| code   | text   | Faculty Code |

Example:

* Engineering
* Physiotherapy
* Economics & Administrative Sciences
* Arts & Design
* Mass Communication

---

# majors

Stores programs/majors inside each faculty.

| Column     | Type   | Description       |
| ---------- | ------ | ----------------- |
| id         | bigint | Primary Key       |
| faculty_id | bigint | FK → faculties.id |
| name       | text   | Major Name        |

Examples:

Engineering:

* Computer and Systems Engineering
* Civil Engineering
* Mechatronics Engineering

Business:

* Accounting and Finance
* Marketing
* BIS

---

# certificate_types

Stores secondary education certificate categories.

| Column | Type   | Description      |
| ------ | ------ | ---------------- |
| id     | bigint | Primary Key      |
| name   | text   | Certificate Type |

Examples:

* Egyptian Thanaweya Amma
* American Diploma
* IGCSE

---

# certificate_specializations

Stores certificate specializations.

| Column              | Type   | Description               |
| ------------------- | ------ | ------------------------- |
| id                  | bigint | Primary Key               |
| certificate_type_id | bigint | FK → certificate_types.id |
| name                | text   | Specialization            |

Examples:

* Scientific Math
* Scientific Science
* Literature

---

# faculty_specialization_rules

Defines which faculties are available for each certificate specialization.

| Column                        | Type   | Description                         |
| ----------------------------- | ------ | ----------------------------------- |
| id                            | bigint | Primary Key                         |
| faculty_id                    | bigint | FK → faculties.id                   |
| certificate_specialization_id | bigint | FK → certificate_specializations.id |

Purpose:

Used to dynamically filter faculty choices during admission.

---

# applications

Stores admission applications submitted by applicants.

| Column                        | Type    |
| ----------------------------- | ------- |
| id                            | uuid    |
| application_number            | text    |
| user_id                       | uuid    |
| applicant_type                | text    |
| semester                      | text    |
| full_name_en                  | text    |
| full_name_ar                  | text    |
| nationality                   | text    |
| national_id                   | text    |
| email                         | text    |
| guardian_email                | text    |
| mobile                        | text    |
| alternate_mobile              | text    |
| date_of_birth                 | date    |
| gender                        | text    |
| certificate_type_id           | bigint  |
| certificate_specialization_id | bigint  |
| school_name                   | text    |
| high_school_grade             | numeric |
| faculty_id                    | bigint  |
| major_id                      | bigint  |
| status                        | text    |

Status Values:

* pending
* approved
* rejected

Relationships:

* certificate_type_id → certificate_types.id
* certificate_specialization_id → certificate_specializations.id
* faculty_id → faculties.id
* major_id → majors.id

---

# application_documents

Stores uploaded admission documents.

| Column         | Type |
| -------------- | ---- |
| id             | uuid |
| application_id | uuid |
| document_type  | text |
| file_path      | text |

Relationships:

* application_id → applications.id

Document Types:

* national_id
* passport
* guardian_id
* birth_certificate
* high_school_certificate
* personal_photo
* other

---

# students

Stores approved applicants who become students.

| Column           | Type    |
| ---------------- | ------- |
| id               | uuid    |
| student_code     | text    |
| faculty_id       | bigint  |
| major_id         | bigint  |
| max_credit_hours | integer |

Relationships:

* id → auth.users.id
* faculty_id → faculties.id
* major_id → majors.id

---

# courses

Stores available academic courses.

| Column       | Type    |
| ------------ | ------- |
| id           | bigint  |
| course_code  | text    |
| course_name  | text    |
| faculty_id   | bigint  |
| credit_hours | integer |

Relationships:

* faculty_id → faculties.id

Examples:

* CS101
* MATH101
* PHY101

---

# course_prerequisites

Stores prerequisite relationships between courses.

| Column                 | Type   |
| ---------------------- | ------ |
| id                     | bigint |
| course_id              | bigint |
| prerequisite_course_id | bigint |

Relationships:

* course_id → courses.id
* prerequisite_course_id → courses.id

Example:

CS201 requires CS101

---

# completed_courses

Stores courses successfully completed by students.

| Column     | Type   |
| ---------- | ------ |
| id         | uuid   |
| student_id | uuid   |
| course_id  | bigint |
| grade      | text   |
| semester   | text   |

Relationships:

* student_id → students.id
* course_id → courses.id

Purpose:

Used for prerequisite validation.

---

# student_available_courses

Stores courses that administrators allow a student to register.

| Column     | Type   |
| ---------- | ------ |
| id         | uuid   |
| student_id | uuid   |
| course_id  | bigint |

Relationships:

* student_id → students.id
* course_id → courses.id

Purpose:

Controls which courses appear during registration.

---

# registrations

Stores course registrations.

| Column     | Type   |
| ---------- | ------ |
| id         | uuid   |
| student_id | uuid   |
| course_id  | bigint |
| semester   | text   |
| status     | text   |

Relationships:

* student_id → students.id
* course_id → courses.id

Status Values:

* registered
* dropped

Purpose:

Stores actual student course enrollment.

---

# profiles

Stores user profile information.

| Column    | Type |
| --------- | ---- |
| id        | uuid |
| full_name | text |
| role      | text |

Role Values:

* student
* admin

Relationships:

* id → auth.users.id

Purpose:

Used for authentication and role-based routing.
