USE QuanLyCuaHangTienLoi;
GO

-- Stored procedure to authenticate user
CREATE PROCEDURE app.sp_AuthenticateUser
    @Username NVARCHAR(50),
    @PasswordHash NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        a.AccountID,
        a.Username,
        a.Email,
        r.RoleID,
        r.RoleName,
        e.EmployeeID,
        e.FullName AS EmployeeName
    FROM 
        app.Account a
    INNER JOIN 
        app.Role r ON a.RoleID = r.RoleID
    LEFT JOIN 
        app.Employee e ON e.AccountID = a.AccountID
    WHERE 
        a.Username = @Username 
        AND a.PasswordHash = @PasswordHash
        AND a.IsActive = 1;
END
GO

-- Stored procedure to create new account
CREATE PROCEDURE app.sp_CreateAccount
    @Username NVARCHAR(50),
    @PasswordHash NVARCHAR(128),
    @PasswordSalt NVARCHAR(128),
    @Email NVARCHAR(100),
    @RoleID INT,
    @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if username already exists
    IF EXISTS (SELECT 1 FROM app.Account WHERE Username = @Username)
    BEGIN
        RAISERROR('Username already exists', 16, 1);
        RETURN;
    END
    
    -- Insert new account
    INSERT INTO app.Account (Username, PasswordHash, PasswordSalt, Email, RoleID, CreatedDate)
    VALUES (@Username, @PasswordHash, @PasswordSalt, @Email, @RoleID, GETDATE());
    
    -- Get the new account ID
    DECLARE @AccountID INT = SCOPE_IDENTITY();
    
    -- Log the activity
    INSERT INTO app.ActivityLog (AccountID, ActivityType, EntityType, EntityID, Description)
    VALUES (@CreatedBy, 'Create', 'Account', @AccountID, 'Created new account: ' + @Username);
    
    -- Return the new account ID
    SELECT @AccountID AS AccountID;
END
GO

-- Stored procedure to update account
CREATE PROCEDURE app.sp_UpdateAccount
    @AccountID INT,
    @Email NVARCHAR(100),
    @RoleID INT,
    @IsActive BIT,
    @ModifiedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get current account data for logging
    DECLARE @OldEmail NVARCHAR(100), @OldRoleID INT, @OldIsActive BIT, @Username NVARCHAR(50);
    SELECT 
        @OldEmail = Email, 
        @OldRoleID = RoleID, 
        @OldIsActive = IsActive,
        @Username = Username
    FROM 
        app.Account 
    WHERE 
        AccountID = @AccountID;
    
    -- Update account
    UPDATE app.Account
    SET 
        Email = @Email,
        RoleID = @RoleID,
        IsActive = @IsActive,
        ModifiedDate = GETDATE()
    WHERE 
        AccountID = @AccountID;
    
    -- Log the activity
    INSERT INTO app.ActivityLog (AccountID, ActivityType, EntityType, EntityID, Description)
    VALUES (
        @ModifiedBy, 
        'Update', 
        'Account', 
        @AccountID, 
        'Updated account: ' + @Username
    );
    
    -- Return success
    SELECT 'Account updated successfully' AS Result;
END
GO

-- Stored procedure to change password
CREATE PROCEDURE app.sp_ChangePassword
    @AccountID INT,
    @OldPasswordHash NVARCHAR(128),
    @NewPasswordHash NVARCHAR(128),
    @NewPasswordSalt NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if old password is correct
    IF NOT EXISTS (SELECT 1 FROM app.Account WHERE AccountID = @AccountID AND PasswordHash = @OldPasswordHash)
    BEGIN
        RAISERROR('Current password is incorrect', 16, 1);
        RETURN;
    END
    
    -- Update password
    UPDATE app.Account
    SET 
        PasswordHash = @NewPasswordHash,
        PasswordSalt = @NewPasswordSalt,
        ModifiedDate = GETDATE()
    WHERE 
        AccountID = @AccountID;
    
    -- Log the activity
    INSERT INTO app.ActivityLog (AccountID, ActivityType, EntityType, EntityID, Description)
    VALUES (@AccountID, 'Update', 'Account', @AccountID, 'Changed password');
    
    -- Return success
    SELECT 'Password changed successfully' AS Result;
END
GO

-- Stored procedure to get all accounts
CREATE PROCEDURE app.sp_GetAllAccounts
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        a.AccountID,
        a.Username,
        a.Email,
        r.RoleName,
        a.LastLogin,
        a.CreatedDate,
        a.IsActive,
        e.FullName AS EmployeeName
    FROM 
        app.Account a
    INNER JOIN 
        app.Role r ON a.RoleID = r.RoleID
    LEFT JOIN 
        app.Employee e ON e.AccountID = a.AccountID
    ORDER BY 
        a.Username;
END
GO

PRINT 'Account management stored procedures created successfully';