USE QuanLyCuaHangTienLoi;
GO

-- Stored procedure to get all employees
CREATE PROCEDURE app.sp_GetAllEmployees
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.FullName,
        e.Gender,
        e.DateOfBirth,
        e.PhoneNumber,
        e.Address,
        e.IdentityCard,
        e.Position,
        e.HireDate,
        e.Salary,
        e.IsActive,
        a.AccountID,
        a.Username,
        r.RoleName
    FROM 
        app.Employee e
    LEFT JOIN 
        app.Account a ON e.AccountID = a.AccountID
    LEFT JOIN 
        app.Role r ON a.RoleID = r.RoleID
    ORDER BY 
        e.FullName;
END
GO

-- Stored procedure to get employee by ID
CREATE PROCEDURE app.sp_GetEmployeeByID
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get employee details
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.FullName,
        e.Gender,
        e.DateOfBirth,
        e.PhoneNumber,
        e.Address,
        e.IdentityCard,
        e.Position,
        e.HireDate,
        e.Salary,
        e.IsActive,
        e.CreatedDate,
        e.ModifiedDate,
        a.AccountID,
        a.Username,
        a.Email,
        a.RoleID,
        r.RoleName,
        a.LastLogin,
        a.IsActive AS AccountIsActive
    FROM 
        app.Employee e
    LEFT JOIN 
        app.Account a ON e.AccountID = a.AccountID
    LEFT JOIN 
        app.Role r ON a.RoleID = r.RoleID
    WHERE 
        e.EmployeeID = @EmployeeID;
    
    -- Get employee attendance records
    SELECT TOP 30
        AttendanceID,
        AttendanceDate,
        TimeIn,
        TimeOut,
        Status,
        Note
    FROM 
        app.EmployeeAttendance
    WHERE 
        EmployeeID = @EmployeeID
    ORDER BY 
        AttendanceDate DESC;
    
    -- Get employee schedule
    SELECT 
        ScheduleID,
        WorkDate,
        StartTime,
        EndTime
    FROM 
        app.EmployeeSchedule
    WHERE 
        EmployeeID = @EmployeeID
        AND WorkDate >= GETDATE()
    ORDER BY 
        WorkDate, StartTime;
    
    -- Get recent orders processed by employee
    SELECT TOP 10
        o.OrderID,
        o.OrderCode,
        o.OrderDate,
        o.FinalAmount,
        o.PaymentStatus,
        COUNT(od.OrderDetailID) AS ItemCount
    FROM 
        app.Order o
    INNER JOIN 
        app.OrderDetail od ON o.OrderID = od.OrderID
    WHERE 
        o.EmployeeID = @EmployeeID
    GROUP BY 
        o.OrderID, o.OrderCode, o.OrderDate, o.FinalAmount, o.PaymentStatus
    ORDER BY 
        o.OrderDate DESC;
END
GO

-- Stored procedure to create new employee
CREATE PROCEDURE app.sp_CreateEmployee
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Gender NVARCHAR(10) = NULL,
    @DateOfBirth DATE = NULL,
    @PhoneNumber NVARCHAR(20) = NULL,
    @Address NVARCHAR(200) = NULL,
    @IdentityCard NVARCHAR(20) = NULL,
    @Position NVARCHAR(50) = NULL,
    @HireDate DATE = NULL,
    @Salary DECIMAL(18, 2) = NULL,
    @AccountID INT = NULL,
    @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Insert new employee
    INSERT INTO app.Employee (
        FirstName, LastName, Gender, DateOfBirth, 
        PhoneNumber, Address, IdentityCard, Position, 
        HireDate, Salary, AccountID, IsActive, CreatedDate
    )
    VALUES (
        @FirstName, @LastName, @Gender, @DateOfBirth, 
        @PhoneNumber, @Address, @IdentityCard, @Position, 
        ISNULL(@HireDate, GETDATE()), @Salary, @AccountID, 1, GETDATE()
    );
    
    -- Get the new employee ID
    DECLARE @EmployeeID INT = SCOPE_IDENTITY();
    
    -- Log the activity
    INSERT INTO app.ActivityLog (
        AccountID, ActivityType, EntityType, EntityID, Description
    )
    VALUES (
        @CreatedBy, 'Create', 'Employee', @EmployeeID, 
        'Created new employee: ' + @FirstName + ' ' + @LastName
    );
    
    -- Return the new employee ID
    SELECT @EmployeeID AS EmployeeID;
END
GO

-- Stored procedure to update employee
CREATE PROCEDURE app.sp_UpdateEmployee
    @EmployeeID INT,
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Gender NVARCHAR(10) = NULL,
    @DateOfBirth DATE = NULL,
    @PhoneNumber NVARCHAR(20) = NULL,
    @Address NVARCHAR(200) = NULL,
    @IdentityCard NVARCHAR(20) = NULL,
    @Position NVARCHAR(50) = NULL,
    @HireDate DATE = NULL,
    @Salary DECIMAL(18, 2) = NULL,
    @AccountID INT = NULL,
    @IsActive BIT = 1,
    @ModifiedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get current employee data for logging
    DECLARE @OldFirstName NVARCHAR(50), @OldLastName NVARCHAR(50);
    SELECT 
        @OldFirstName = FirstName,
        @OldLastName = LastName
    FROM 
        app.Employee 
    WHERE 
        EmployeeID = @EmployeeID;
    
    -- Update employee
    UPDATE app.Employee
    SET 
        FirstName = @FirstName,
        LastName = @LastName,
        Gender = @Gender,
        DateOfBirth = @DateOfBirth,
        PhoneNumber = @PhoneNumber,
        Address = @Address,
        IdentityCard = @IdentityCard,
        Position = @Position,
        HireDate = @HireDate,
        Salary = @Salary,
        AccountID = @AccountID,
        IsActive = @IsActive,
        ModifiedDate = GETDATE()
    WHERE 
        EmployeeID = @EmployeeID;
    
    -- Log the activity
    INSERT INTO app.ActivityLog (
        AccountID, ActivityType, EntityType, EntityID, Description
    )
    VALUES (
        @ModifiedBy, 'Update', 'Employee', @EmployeeID, 
        'Updated employee: ' + @OldFirstName + ' ' + @OldLastName
    );
    
    -- Return success
    SELECT 'Employee updated successfully' AS Result;
END
GO

-- Stored procedure to create employee with account
CREATE PROCEDURE app.sp_CreateEmployeeWithAccount
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Gender NVARCHAR(10) = NULL,
    @DateOfBirth DATE = NULL,
    @PhoneNumber NVARCHAR(20) = NULL,
    @Address NVARCHAR(200) = NULL,
    @IdentityCard NVARCHAR(20) = NULL,
    @Position NVARCHAR(50) = NULL,
    @HireDate DATE = NULL,
    @Salary DECIMAL(18, 2) = NULL,
    @Username NVARCHAR(50),
    @PasswordHash NVARCHAR(128),
    @PasswordSalt NVARCHAR(128),
    @Email NVARCHAR(100) = NULL,
    @RoleID INT,
    @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Check if username already exists
        IF EXISTS (SELECT 1 FROM app.Account WHERE Username = @Username)
        BEGIN
            RAISERROR('Username already exists', 16, 1);
            ROLLBACK;
            RETURN;
        END
        
        -- Create account
        INSERT INTO app.Account (
            Username, PasswordHash, PasswordSalt, Email, RoleID, CreatedDate
        )
        VALUES (
            @Username, @PasswordHash, @PasswordSalt, @Email, @RoleID, GETDATE()
        );
        
        -- Get the new account ID
        DECLARE @AccountID INT = SCOPE_IDENTITY();
        
        -- Create employee
        INSERT INTO app.Employee (
            FirstName, LastName, Gender, DateOfBirth, 
            PhoneNumber, Address, IdentityCard, Position, 
            HireDate, Salary, AccountID, IsActive, CreatedDate
        )
        VALUES (
            @FirstName, @LastName, @Gender, @DateOfBirth, 
            @PhoneNumber, @Address, @IdentityCard, @Position, 
            ISNULL(@HireDate, GETDATE()), @Salary, @AccountID, 1, GETDATE()
        );
        
        -- Get the new employee ID
        DECLARE @EmployeeID INT = SCOPE_IDENTITY();
        
        -- Log the activity
        INSERT INTO app.ActivityLog (
            AccountID, ActivityType, EntityType, EntityID, Description
        )
        VALUES (
            @CreatedBy, 'Create', 'Employee', @EmployeeID, 
            'Created new employee with account: ' + @FirstName + ' ' + @LastName + ' (' + @Username + ')'
        );
        
        COMMIT;
        
        -- Return the new IDs
        SELECT @EmployeeID AS EmployeeID, @AccountID AS AccountID;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END
GO

-- Stored procedure to search employees
CREATE PROCEDURE app.sp_SearchEmployees
    @SearchTerm NVARCHAR(100),
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.FullName,
        e.Gender,
        e.PhoneNumber,
        e.Position,
        e.HireDate,
        e.Salary,
        e.IsActive,
        a.Username,
        r.RoleName
    FROM 
        app.Employee e
    LEFT JOIN 
        app.Account a ON e.AccountID = a.AccountID
    LEFT JOIN 
        app.Role r ON a.RoleID = r.RoleID
    WHERE 
        (
            e.FirstName LIKE '%' + @SearchTerm + '%' OR
            e.LastName LIKE '%' + @SearchTerm + '%' OR
            e.FullName LIKE '%' + @SearchTerm + '%' OR
            e.PhoneNumber LIKE '%' + @SearchTerm + '%' OR
            e.Position LIKE '%' + @SearchTerm + '%' OR
            e.IdentityCard LIKE '%' + @SearchTerm + '%' OR
            a.Username LIKE '%' + @SearchTerm + '%'
        )
        AND (@IsActive IS NULL OR e.IsActive = @IsActive)
    ORDER BY 
        e.FullName;
END
GO

-- Stored procedure to record employee attendance
CREATE PROCEDURE app.sp_RecordEmployeeAttendance
    @EmployeeID INT,
    @AttendanceDate DATE,
    @TimeIn TIME = NULL,
    @TimeOut TIME = NULL,
    @Status NVARCHAR(20),
    @Note NVARCHAR(200) = NULL,
    @RecordedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if attendance record already exists for this date
    IF EXISTS (SELECT 1 FROM app.EmployeeAttendance WHERE EmployeeID = @EmployeeID AND AttendanceDate = @AttendanceDate)
    BEGIN
        -- Update existing record
        UPDATE app.EmployeeAttendance
        SET 
            TimeIn = ISNULL(@TimeIn, TimeIn),
            TimeOut = ISNULL(@TimeOut, TimeOut),
            Status = @Status,
            Note = ISNULL(@Note, Note)
        WHERE 
            EmployeeID = @EmployeeID AND AttendanceDate = @AttendanceDate;
    END
    ELSE
    BEGIN
        -- Insert new record
        INSERT INTO app.EmployeeAttendance (
            EmployeeID, AttendanceDate, TimeIn, TimeOut, Status, Note
        )
        VALUES (
            @EmployeeID, @AttendanceDate, @TimeIn, @TimeOut, @Status, @Note
        );
    END
    
    -- Get employee name for logging
    DECLARE @EmployeeName NVARCHAR(100);
    SELECT @EmployeeName = FullName FROM app.Employee WHERE EmployeeID = @EmployeeID;
    
    -- Log the activity
    INSERT INTO app.ActivityLog (
        AccountID, ActivityType, EntityType, EntityID, Description
    )
    VALUES (
        @RecordedBy, 'Record', 'Attendance', @EmployeeID, 
        'Recorded attendance for ' + @EmployeeName + ' on ' + CONVERT(NVARCHAR, @AttendanceDate, 103) + 
        ' - Status: ' + @Status
    );
    
    -- Return success
    SELECT 'Attendance recorded successfully' AS Result;
END
GO

PRINT 'Employee management stored procedures created successfully';