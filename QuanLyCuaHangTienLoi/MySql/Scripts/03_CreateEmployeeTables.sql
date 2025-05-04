USE QuanLyCuaHangTienLoi;
GO

-- Create Employee table
CREATE TABLE app.Employee (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    AccountID INT FOREIGN KEY REFERENCES app.Account(AccountID),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    FullName AS (FirstName + ' ' + LastName) PERSISTED,
    Gender NVARCHAR(10),
    DateOfBirth DATE,
    PhoneNumber NVARCHAR(20),
    Address NVARCHAR(200),
    IdentityCard NVARCHAR(20),
    Position NVARCHAR(50),
    HireDate DATE DEFAULT GETDATE(),
    Salary DECIMAL(18, 2),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME
);

-- Create EmployeeSchedule table
CREATE TABLE app.EmployeeSchedule (
    ScheduleID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT FOREIGN KEY REFERENCES app.Employee(EmployeeID),
    WorkDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    CreatedBy INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME
);

-- Create EmployeeAttendance table
CREATE TABLE app.EmployeeAttendance (
    AttendanceID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT FOREIGN KEY REFERENCES app.Employee(EmployeeID),
    AttendanceDate DATE NOT NULL,
    TimeIn TIME,
    TimeOut TIME,
    Status NVARCHAR(20), -- Present, Absent, Late, etc.
    Note NVARCHAR(200),
    CreatedDate DATETIME DEFAULT GETDATE()
);

PRINT 'Employee tables created successfully';