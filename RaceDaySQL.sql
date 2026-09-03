--create roles and users tables
--created events table with fk to users
--create eventscategories Table
IF DB_ID('RaceDayDB') IS NULL
BEGIN
    CREATE DATABASE RaceDayDB;
END
GO

USE RaceDayDB;
GO


IF OBJECT_ID('dbo.Results', 'U') IS NOT NULL DROP TABLE dbo.Results;
IF OBJECT_ID('dbo.Enrollments', 'U') IS NOT NULL DROP TABLE dbo.Enrollments;
IF OBJECT_ID('dbo.EventCategories', 'U') IS NOT NULL DROP TABLE dbo.EventCategories;
IF OBJECT_ID('dbo.Events', 'U') IS NOT NULL DROP TABLE dbo.Events;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
IF OBJECT_ID('dbo.Roles', 'U') IS NOT NULL DROP TABLE dbo.Roles;
GO

--add null and not null constraints to the table
CREATE TABLE dbo.Roles (
    RoleID      INT IDENTITY(1,1) PRIMARY KEY,
    RoleName    NVARCHAR(50) NOT NULL UNIQUE
);
GO


CREATE TABLE dbo.Users (
    UserID          INT IDENTITY(1,1) PRIMARY KEY,
    RoleID          INT NOT NULL,
    FullName        NVARCHAR(100) NOT NULL,
    Email           NVARCHAR(150) NOT NULL UNIQUE,
    Password        NVARCHAR(255) NOT NULL,     -- store a hashed password, never plain text
    PhoneNumber     NVARCHAR(20)  NULL,
    CreatedDate     DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleID)
        REFERENCES dbo.Roles(RoleID)
);
GO


CREATE TABLE dbo.Events (
    EventID         INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserID     INT NOT NULL,
    EventName       NVARCHAR(150) NOT NULL,
    EventType       NVARCHAR(50)  NOT NULL,     -- e.g. Marathon, Cycling, Park Run
    EventDate       DATE NOT NULL,
    Province        NVARCHAR(50)  NOT NULL,
    Venue           NVARCHAR(150) NOT NULL,
    Description     NVARCHAR(MAX) NULL,
    CreatedDate     DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Events_Users FOREIGN KEY (OrganiserID)
        REFERENCES dbo.Users(UserID)
);
GO


CREATE TABLE dbo.EventCategories (
    CategoryID      INT IDENTITY(1,1) PRIMARY KEY,
    EventID         INT NOT NULL,
    CategoryName    NVARCHAR(100) NOT NULL,     -- e.g. 10km, 21km, 42km
    DistanceKm      DECIMAL(6,2) NOT NULL,
    EntryFee        DECIMAL(8,2) NOT NULL DEFAULT (0),
    MaxParticipants INT NOT NULL,
    CONSTRAINT FK_EventCategories_Events FOREIGN KEY (EventID)
        REFERENCES dbo.Events(EventID)
);
GO


CREATE TABLE dbo.Enrollments (
    EnrollmentID    INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantID   INT NOT NULL,
    CategoryID      INT NOT NULL,
    EnrolmentDate   DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
    Status          NVARCHAR(20) NOT NULL DEFAULT ('Pending'),
        CONSTRAINT CK_Enrollments_Status CHECK (Status IN ('Pending','Confirmed','Cancelled')),
    CONSTRAINT FK_Enrollments_Users FOREIGN KEY (ParticipantID)
        REFERENCES dbo.Users(UserID),
    CONSTRAINT FK_Enrollments_Categories FOREIGN KEY (CategoryID)
        REFERENCES dbo.EventCategories(CategoryID),
    CONSTRAINT UQ_Enrollments_Participant_Category UNIQUE (ParticipantID, CategoryID)
);
GO
--create enrolments table with unique constraint
--create rseults table with FK constraints
CREATE TABLE dbo.Results (
    ResultID            INT IDENTITY(1,1) PRIMARY KEY,
    EnrollmentID        INT NOT NULL UNIQUE,      -- UNIQUE enforces the 0..1 cardinality from the ERD
    CapturedByUserID    INT NOT NULL,
    FinishTime          TIME NOT NULL,
    Position             INT NULL,
    CapturedDate         DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Results_Enrollments FOREIGN KEY (EnrollmentID)
        REFERENCES dbo.Enrollments(EnrollmentID),
    CONSTRAINT FK_Results_Users FOREIGN KEY (CapturedByUserID)
        REFERENCES dbo.Users(UserID)
);
GO




-- Roles
INSERT INTO dbo.Roles (RoleName) VALUES
('Admin'),
('Organiser'),
('Participant');
GO

-- Users: 2 Organisers, 2 Participants (RoleID 2 = Organiser, 3 = Participant)
INSERT INTO dbo.Users (RoleID, FullName, Email, Password, PhoneNumber) VALUES
(2, N'Thabo Mokoena',   N'thabo.mokoena@raceday.co.za',   N'HASHED_PASSWORD_1', N'0821234567'),
(2, N'Lerato Nkosi',    N'lerato.nkosi@raceday.co.za',    N'HASHED_PASSWORD_2', N'0837654321'),
(3, N'Johan van Wyk',   N'johan.vanwyk@example.com',      N'HASHED_PASSWORD_3', N'0731239876'),
(3, N'Amahle Dlamini',  N'amahle.dlamini@example.com',    N'HASHED_PASSWORD_4', N'0769871234');
GO

-- Events: 3 events, organised by the two organisers (UserID 1 and 2)
INSERT INTO dbo.Events (OrganiserID, EventName, EventType, EventDate, Province, Venue, Description) VALUES
(1, N'Pietermaritzburg to Durban Classic', N'Marathon', '2026-06-14', N'KwaZulu-Natal', N'Comrades Marathon Route', N'A gruelling ultramarathon between Pietermaritzburg and Durban.'),
(2, N'Cape Town Cycle Tour',               N'Cycling',  '2026-03-08', N'Western Cape',  N'Sea Point Promenade',    N'A scenic cycling tour around the Cape Peninsula.'),
(1, N'Soweto Community Park Run',          N'Park Run', '2026-04-25', N'Gauteng',       N'Soweto Athletics Track', N'A free weekly timed 5km run open to all fitness levels.');
GO

-- Event Categories: at least one category per event
INSERT INTO dbo.EventCategories (EventID, CategoryName, DistanceKm, EntryFee, MaxParticipants) VALUES
(1, N'Ultra 87km',   87.00, 950.00, 20000),
(1, N'Novice 21km',  21.10, 450.00, 5000),
(2, N'Short Route 55km', 55.00, 650.00, 15000),
(2, N'Long Route 109km', 109.00, 850.00, 15000),
(3, N'Standard 5km', 5.00, 0.00, 500);
GO

-- Enrollments: participants (UserID 3 and 4) entering categories
INSERT INTO dbo.Enrollments (ParticipantID, CategoryID, Status) VALUES
(3, 1, N'Confirmed'),   -- Johan enters the Ultra 87km
(4, 2, N'Confirmed'),   -- Amahle enters the Novice 21km
(3, 3, N'Pending'),     -- Johan enters the Cycle Tour Short Route
(4, 5, N'Confirmed');   -- Amahle enters the Park Run
GO

-- Results: results captured for some of the confirmed enrolments
INSERT INTO dbo.Results (EnrollmentID, CapturedByUserID, FinishTime, Position) VALUES
(1, 1, '07:45:12', 1523),  -- captured by organiser Thabo
(2, 1, '01:58:30', 210),
(4, 2, '00:22:45', 15);    -- captured by organiser Lerato
GO

PRINT 'RaceDay database schema and seed data created successfully.';
