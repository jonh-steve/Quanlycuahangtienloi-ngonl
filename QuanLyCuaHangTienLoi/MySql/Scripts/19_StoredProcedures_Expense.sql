USE QuanLyCuaHangTienLoi;
GO

-- Stored procedure to get all expense types
CREATE PROCEDURE app.sp_GetAllExpenseTypes
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ExpenseTypeID,
        TypeName,
        Description,
        IsActive
    FROM 
        app.ExpenseType
    ORDER BY 
        TypeName;
END
GO

-- Stored procedure to create expense type
CREATE PROCEDURE app.sp_CreateExpenseType
    @TypeName NVARCHAR(100),
    @Description NVARCHAR(200) = NULL,
    @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if expense type already exists
    IF EXISTS (SELECT 1 FROM app.ExpenseType WHERE TypeName = @TypeName)
    BEGIN
        RAISERROR('Expense type already exists', 16, 1);
        RETURN;
    END
    
    -- Insert new expense type
    INSERT INTO app.ExpenseType (
        TypeName, Description, IsActive
    )
    VALUES (
        @TypeName, @Description, 1
    );
    
    -- Get the new expense type ID
    DECLARE @ExpenseTypeID INT = SCOPE_IDENTITY();
    
    -- Log the activity
    INSERT INTO app.ActivityLog (
        AccountID, ActivityType, EntityType, EntityID, Description
    )
    VALUES (
        @CreatedBy, 'Create', 'ExpenseType', @ExpenseTypeID, 
        'Created new expense type: ' + @TypeName
    );
    
    -- Return the new expense type ID
    SELECT @ExpenseTypeID AS ExpenseTypeID;
END
GO

-- Stored procedure to update expense type
CREATE PROCEDURE app.sp_UpdateExpenseType
    @ExpenseTypeID INT,
    @TypeName NVARCHAR(100),
    @Description NVARCHAR(200) = NULL,
    @IsActive BIT = 1,
    @ModifiedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if expense type already exists (excluding current type)
    IF EXISTS (
        SELECT 1 
        FROM app.ExpenseType 
        WHERE TypeName = @TypeName 
        AND ExpenseTypeID <> @ExpenseTypeID
    )
    BEGIN
        RAISERROR('Expense type already exists', 16, 1);
        RETURN;
    END
    
    -- Get current expense type data for logging
    DECLARE @OldTypeName NVARCHAR(100);
    SELECT @OldTypeName = TypeName FROM app.ExpenseType WHERE ExpenseTypeID = @ExpenseTypeID;
    
    -- Update expense type
    UPDATE app.ExpenseType
    SET 
        TypeName = @TypeName,
        Description = @Description,
        IsActive = @IsActive
    WHERE 
        ExpenseTypeID = @ExpenseTypeID;
    
    -- Log the activity
    INSERT INTO app.ActivityLog (
        AccountID, ActivityType, EntityType, EntityID, Description
    )
    VALUES (
        @ModifiedBy, 'Update', 'ExpenseType', @ExpenseTypeID, 
        'Updated expense type: ' + @OldTypeName
    );
    
    -- Return success
    SELECT 'Expense type updated successfully' AS Result;
END
GO

-- Stored procedure to get all expenses
CREATE PROCEDURE app.sp_GetAllExpenses
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @ExpenseTypeID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.ExpenseID,
        e.Amount,
        e.ExpenseDate,
        e.Description,
        et.ExpenseTypeID,
        et.TypeName AS ExpenseType,
        emp.EmployeeID,
        emp.FullName AS EmployeeName,
        e.CreatedDate
    FROM 
        app.Expense e
    INNER JOIN 
        app.ExpenseType et ON e.ExpenseTypeID = et.ExpenseTypeID
    INNER JOIN 
        app.Employee emp ON e.EmployeeID = emp.EmployeeID
    WHERE 
        (@StartDate IS NULL OR e.ExpenseDate >= @StartDate)
        AND (@EndDate IS NULL OR e.ExpenseDate <= @EndDate)
        AND (@ExpenseTypeID IS NULL OR e.ExpenseTypeID = @ExpenseTypeID)
    ORDER BY 
        e.ExpenseDate DESC, e.CreatedDate DESC;
END
GO

-- Stored procedure to get expense by ID
CREATE PROCEDURE app.sp_GetExpenseByID
    @ExpenseID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.ExpenseID,
        e.Amount,
        e.ExpenseDate,
        e.Description,
        et.ExpenseTypeID,
        et.TypeName AS ExpenseType,
        emp.EmployeeID,
        emp.FullName AS EmployeeName,
        e.CreatedDate,
        e.ModifiedDate
    FROM 
        app.Expense e
    INNER JOIN 
        app.ExpenseType et ON e.ExpenseTypeID = et.ExpenseTypeID
    INNER JOIN 
        app.Employee emp ON e.EmployeeID = emp.EmployeeID
    WHERE 
        e.ExpenseID = @ExpenseID;
END
GO

-- Stored procedure to create expense
CREATE PROCEDURE app.sp_CreateExpense
    @ExpenseTypeID INT,
    @Amount DECIMAL(18, 2),
    @ExpenseDate DATE,
    @Description NVARCHAR(500) = NULL,
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Insert new expense
    INSERT INTO app.Expense (
        ExpenseTypeID, Amount, ExpenseDate, Description, EmployeeID, CreatedDate
    )
    VALUES (
        @ExpenseTypeID, @Amount, @ExpenseDate, @Description, @EmployeeID, GETDATE()
    );
    
    -- Get the new expense ID
    DECLARE @ExpenseID INT = SCOPE_IDENTITY();
    
    -- Get expense type name for logging
    DECLARE @ExpenseTypeName NVARCHAR(100);
    SELECT @ExpenseTypeName = TypeName FROM app.ExpenseType WHERE ExpenseTypeID = @ExpenseTypeID;
    
    -- Log the activity
    INSERT INTO app.ActivityLog (
        AccountID, ActivityType, EntityType, EntityID, Description
    )
    VALUES (
        @EmployeeID, 'Create', 'Expense', @ExpenseID, 
        'Created new expense: ' + @ExpenseTypeName + ' - ' + CAST(@Amount AS NVARCHAR) + ' VND'
    );
    
    -- Return the new expense ID
    SELECT @ExpenseID AS ExpenseID;
END
GO

-- Stored procedure to update expense
CREATE PROCEDURE app.sp_UpdateExpense
    @ExpenseID INT,
    @ExpenseTypeID INT,
    @Amount DECIMAL(18, 2),
    @ExpenseDate DATE,
    @Description NVARCHAR(500) = NULL,
    @ModifiedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get current expense data for logging
    DECLARE @OldAmount DECIMAL(18, 2), @OldExpenseTypeID INT, @OldExpenseTypeName NVARCHAR(100);
    SELECT 
        @OldAmount = e.Amount,
        @OldExpenseTypeID = e.ExpenseTypeID
    FROM 
        app.Expense e
    WHERE 
        e.ExpenseID = @ExpenseID;
    
    SELECT @OldExpenseTypeName = TypeName FROM app.ExpenseType WHERE ExpenseTypeID = @OldExpenseTypeID;
    
    -- Update expense
    UPDATE app.Expense
    SET 
        ExpenseTypeID = @ExpenseTypeID,
        Amount = @Amount,
        ExpenseDate = @ExpenseDate,
        Description = @Description,
        ModifiedDate = GETDATE()
    WHERE 
        ExpenseID = @ExpenseID;
    
    -- Get new expense type name for logging
    DECLARE @NewExpenseTypeName NVARCHAR(100);
    SELECT @NewExpenseTypeName = TypeName FROM app.ExpenseType WHERE ExpenseTypeID = @ExpenseTypeID;
    
    -- Log the activity
    INSERT INTO app.ActivityLog (
        AccountID, ActivityType, EntityType, EntityID, Description
    )
    VALUES (
        @ModifiedBy, 'Update', 'Expense', @ExpenseID, 
        'Updated expense from ' + @OldExpenseTypeName + ' - ' + CAST(@OldAmount AS NVARCHAR) + ' VND' +
        ' to ' + @NewExpenseTypeName + ' - ' + CAST(@Amount AS NVARCHAR) + ' VND'
    );
    
    -- Return success
    SELECT 'Expense updated successfully' AS Result;
END
GO

-- Stored procedure to delete expense
CREATE PROCEDURE app.sp_DeleteExpense
    @ExpenseID INT,
    @DeletedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get expense data for logging
    DECLARE @Amount DECIMAL(18, 2), @ExpenseTypeName NVARCHAR(100);
    SELECT 
        @Amount = e.Amount,
        @ExpenseTypeName = et.TypeName
    FROM 
        app.Expense e
    INNER JOIN 
        app.ExpenseType et ON e.ExpenseTypeID = et.ExpenseTypeID
    WHERE 
        e.ExpenseID = @ExpenseID;
    
    -- Delete expense
    DELETE FROM app.Expense WHERE ExpenseID = @ExpenseID;
    
    -- Log the activity
    INSERT INTO app.ActivityLog (
        AccountID, ActivityType, EntityType, EntityID, Description
    )
    VALUES (
        @DeletedBy, 'Delete', 'Expense', @ExpenseID, 
        'Deleted expense: ' + @ExpenseTypeName + ' - ' + CAST(@Amount AS NVARCHAR) + ' VND'
    );
    
    -- Return success
    SELECT 'Expense deleted successfully' AS Result;
END
GO

-- Stored procedure to get expense summary by type
CREATE PROCEDURE app.sp_GetExpenseSummaryByType
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        et.ExpenseTypeID,
        et.TypeName,
        COUNT(e.ExpenseID) AS ExpenseCount,
        SUM(e.Amount) AS TotalAmount,
        MIN(e.ExpenseDate) AS FirstExpenseDate,
        MAX(e.ExpenseDate) AS LastExpenseDate
    FROM 
        app.ExpenseType et
    LEFT JOIN 
        app.Expense e ON et.ExpenseTypeID = e.ExpenseTypeID
        AND e.ExpenseDate BETWEEN @StartDate AND @EndDate
    GROUP BY 
        et.ExpenseTypeID, et.TypeName
    ORDER BY 
        SUM(e.Amount) DESC;
END
GO

-- Stored procedure to get expense summary by date
CREATE PROCEDURE app.sp_GetExpenseSummaryByDate
    @StartDate DATE,
    @EndDate DATE,
    @GroupBy NVARCHAR(10) = 'Day' -- Day, Week, Month
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @GroupBy = 'Day'
    BEGIN
        SELECT 
            CAST(e.ExpenseDate AS DATE) AS ExpenseDate,
            COUNT(e.ExpenseID) AS ExpenseCount,
            SUM(e.Amount) AS TotalAmount
        FROM 
            app.Expense e
        WHERE 
            e.ExpenseDate BETWEEN @StartDate AND @EndDate
        GROUP BY 
            CAST(e.ExpenseDate AS DATE)
        ORDER BY 
            CAST(e.ExpenseDate AS DATE);
    END
    ELSE IF @GroupBy = 'Week'
    BEGIN
        SELECT 
            DATEPART(YEAR, e.ExpenseDate) AS Year,
            DATEPART(WEEK, e.ExpenseDate) AS WeekNumber,
            MIN(e.ExpenseDate) AS WeekStart,
            COUNT(e.ExpenseID) AS ExpenseCount,
            SUM(e.Amount) AS TotalAmount
        FROM 
            app.Expense e
        WHERE 
            e.ExpenseDate BETWEEN @StartDate AND @EndDate
        GROUP BY 
            DATEPART(YEAR, e.ExpenseDate), DATEPART(WEEK, e.ExpenseDate)
        ORDER BY 
            DATEPART(YEAR, e.ExpenseDate), DATEPART(WEEK, e.ExpenseDate);
    END
    ELSE IF @GroupBy = 'Month'
    BEGIN
        SELECT 
            DATEPART(YEAR, e.ExpenseDate) AS Year,
            DATEPART(MONTH, e.ExpenseDate) AS Month,
            DATENAME(MONTH, e.ExpenseDate) AS MonthName,
            COUNT(e.ExpenseID) AS ExpenseCount,
            SUM(e.Amount) AS TotalAmount
        FROM 
            app.Expense e
        WHERE 
            e.ExpenseDate BETWEEN @StartDate AND @EndDate
        GROUP BY 
            DATEPART(YEAR, e.ExpenseDate), DATEPART(MONTH, e.ExpenseDate), DATENAME(MONTH, e.ExpenseDate)
        ORDER BY 
            DATEPART(YEAR, e.ExpenseDate), DATEPART(MONTH, e.ExpenseDate);
    END
END
GO

PRINT 'Expense management stored procedures created successfully';