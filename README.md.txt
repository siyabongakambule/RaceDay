
 docs/RaceDay_ERD.png  Entity Relationship Diagram - 6 entities: Roles, Users, Events, EventCategories, Enrollments, Results 
 docs/API_Endpoint_Plan.md Full table of every planned API endpoint (method, route, description, role, request body, response) 
 docs/RaceDay_Database.sql SQL Server script: CREATE TABLE statements for all 6 entities with PKs, FKs, and constraints, plus seed INSERT data 

erd does not have a many to many
The SQL script matches the ERD exactly for all 6 entities, their attributes, primary keys, and foreign keys.

One clarification (not a deviation): the ERD marks Enrollments.ParticipantID as an FK but does not draw an explicit relationship line to Users for it (only the CategoryID -> EventCategories relationship is drawn). Since a participant must be a User, the SQL script implements ParticipantID as a foreign key referencing Users(UserID). This completes the relationship implied by the ERD's own "FK" label rather than contradicting it.

A UNIQUE constraint was added on Results.EnrollmentID to enforce the ERD's 0.. 1 cardinality between Enrollments and Results (one enrolment can have at most one result).

this is a three part project and this is the first part
This repository uses a workflow (.github/workflows/validate-docs.yml) that checks the /docs folder exists and contains the required ERD, endpoint plan, and SQL script on every push.

The RaceDay database contains six main entities:
Roles, Users, Events, EventCategories, Enrollments, and Results.

Tech stack (planned for Part 2 onward)

- ASP.NET Core Web API
- SQL Server
- Docker containerisation
- GitHub Actions CI/CD

