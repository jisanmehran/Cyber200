-- 1. Supertype Entity: Person
CREATE TABLE Person (
    PersonID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(20)
);

-- 2. Department Entity
CREATE TABLE Department (
    DeptID VARCHAR(10) PRIMARY KEY,
    DeptName VARCHAR(100) NOT NULL UNIQUE,
    OfficeLocation VARCHAR(100)
);

-- 3. Subtype Entity: Student (Disjoint, total specialization of Person)
CREATE TABLE Student (
    StudentID INT PRIMARY KEY,
    Major VARCHAR(100) NOT NULL,
    Classification VARCHAR(30) NOT NULL,
    TotalCredits INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_student_person
        FOREIGN KEY (StudentID) REFERENCES Person(PersonID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_student_classification
        CHECK (Classification IN ('Freshman', 'Sophomore', 'Junior', 'Senior', 'Graduate')),
    CONSTRAINT chk_student_total_credits
        CHECK (TotalCredits >= 0)
);

-- 4. Subtype Entity: Instructor (Disjoint, total specialization of Person; 1:N with Department)
CREATE TABLE Instructor (
    InstructorID INT PRIMARY KEY,
    OfficeNumber VARCHAR(30),
    Rank VARCHAR(50) NOT NULL,
    Salary DECIMAL(10, 2),
    DeptID VARCHAR(10) NOT NULL,
    CONSTRAINT fk_instructor_person
        FOREIGN KEY (InstructorID) REFERENCES Person(PersonID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_instructor_department
        FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_instructor_salary
        CHECK (Salary IS NULL OR Salary >= 0)
);

-- 5. Course Entity (1:N with Department)
CREATE TABLE Course (
    CourseID INT PRIMARY KEY,
    CourseCode VARCHAR(20) NOT NULL UNIQUE,
    Title VARCHAR(120) NOT NULL,
    Credits INT NOT NULL,
    DeptID VARCHAR(10) NOT NULL,
    CONSTRAINT fk_course_department
        FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_course_credits
        CHECK (Credits > 0)
);

-- 6. Section Entity (Total participation with Course; optional Instructor assignment)
CREATE TABLE Section (
    SectionID INT PRIMARY KEY,
    CourseID INT NOT NULL,
    InstructorID INT NULL, -- Optional assignment per diagram ("N (optional)")
    Semester VARCHAR(20) NOT NULL,
    Year INT NOT NULL,
    Capacity INT NOT NULL,
    AvailableSeats INT NOT NULL,
    CONSTRAINT fk_section_course
        FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_section_instructor
        FOREIGN KEY (InstructorID) REFERENCES Instructor(InstructorID)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_section_semester
        CHECK (Semester IN ('Spring', 'Summer', 'Fall', 'Winter')),
    CONSTRAINT chk_section_year
        CHECK (Year >= 2000),
    CONSTRAINT chk_section_capacity
        CHECK (Capacity > 0),
    CONSTRAINT chk_section_available_seats
        CHECK (AvailableSeats >= 0 AND AvailableSeats <= Capacity)
);

-- 7. Enrollment Associative Entity (M:N between Student and Section with attributes)
CREATE TABLE Enrollment (
    EnrollmentID INT PRIMARY KEY,
    StudentID INT NOT NULL,
    SectionID INT NOT NULL,
    EnrollmentDate DATE NOT NULL DEFAULT CURRENT_DATE,
    Grade VARCHAR(2) NULL, -- NULL while course is in progress
    CONSTRAINT fk_enrollment_student
        FOREIGN KEY (StudentID) REFERENCES Student(StudentID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_enrollment_section
        FOREIGN KEY (SectionID) REFERENCES Section(SectionID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT uq_student_section
        UNIQUE (StudentID, SectionID),
    CONSTRAINT chk_enrollment_grade
        CHECK (Grade IS NULL OR Grade IN ('A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'F', 'W', 'I'))
);
