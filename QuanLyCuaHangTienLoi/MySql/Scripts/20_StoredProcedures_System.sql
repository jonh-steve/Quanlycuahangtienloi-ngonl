USE QuanLyCuaHangTienLoi;
GO

-- Stored procedure to get all system configurations
CREATE PROCEDURE app.sp_GetAllSystemConfigs
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ConfigID,
        ConfigKey,
        ConfigValue,
        Description,
        DataType,
        IsReadOnly,
        CreatedDate,
        ModifiedDate
    FROM 
        app.SystemConfig
    ORDER BY 
        ConfigKey;
END
GO

-- Stored procedure to get system config by key
CREATE PROCEDURE app.sp_GetSystemConfigByKey
    @ConfigKey NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ConfigID,
        ConfigKey,
        ConfigValue,
        Description,
        DataType,
        IsReadOnly,
        CreatedDate,
        ModifiedDate
    FROM 
        app.SystemConfig
    WHERE 
        ConfigKey = @ConfigKey;
END
GO

-- Stored procedure to update system config
CREATE PROCEDURE app.sp_UpdateSystemConfig
    @ConfigKey NVARCHAR(50),
    @ConfigValue NVARCHAR(MAX),
    @ModifiedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if config exists
    IF NOT EXISTS (SELECT 1 FROM app.SystemConfig WHERE ConfigKey = @ConfigKey)
    BEGIN
        RAISERROR('Configuration key does not exist', 16, 1);
        RETURN;
    END
    
    -- Check if config is read-only
    DECLARE @IsReadOnly BIT;
    SELECT @IsReadOnly = IsReadOnly FROM app.SystemConfig WHERE ConfigKey = @ConfigKey;
    
    IF @IsReadOnly = 1
    BEGIN
        RAISERROR('Configuration is read-only and cannot be modified', 16, 1);
        RETURN;
    END
    
    -- Get old value for logging
    DECLARE @OldValue NVARCHAR(MAX);
    SELECT @OldValue = ConfigValue FROM app.SystemConfig WHERE ConfigKey = @ConfigKey;
    
    -- Update config
    UPDATE app.SystemConfig
    SET 
        ConfigValue = @ConfigValue,
        ModifiedDate = GETDATE()
    WHERE 
        ConfigKey = @ConfigKey;
    
    -- Log the activity
    INSERT INTO app.ActivityLog (
        AccountID, ActivityType, EntityType, EntityID, Description, OldValue, NewValue
    )
    VALUES (
        @ModifiedBy, 'Update', 'SystemConfig', 
        (SELECT ConfigID FROM app.SystemConfig WHERE ConfigKey = @ConfigKey), 
        'Updated system configuration: ' + @ConfigKey,
        @OldValue,
        @ConfigValue
    );
    
    -- Return success
    SELECT 'Configuration updated successfully' AS Result;
END
GO

-- Stored procedure to create system config
CREATE PROCEDURE app.sp_CreateSystemConfig
    @ConfigKey NVARCHAR(50),
    @ConfigValue NVARCHAR(MAX),
    @Description NVARCHAR(200) = NULL,
    @DataType NVARCHAR(20) = 'String',
    @IsReadOnly BIT = 0,
    @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if config already exists
    IF EXISTS (SELECT 1 FROM app.SystemConfig WHERE ConfigKey = @ConfigKey)
    BEGIN
        RAISERROR('Configuration key already exists', 16, 1);
        RETURN;
    END
    
    -- Insert new config
    INSERT INTO app.SystemConfig (
        ConfigKey, ConfigValue, Description, DataType, IsReadOnly, CreatedDate
    )
    VALUES (
        @ConfigKey, @ConfigValue, @Description, @DataType, @IsReadOnly, GETDATE()
    );
    
    -- Get the new config ID
    DECLARE @ConfigID INT = SCOPE_IDENTITY();
    
    -- Log the activity
    INSERT INTO app.ActivityLog (
        AccountID, ActivityType, EntityType, EntityID, Description, NewValue
    )
    VALUES (
        @CreatedBy, 'Create', 'SystemConfig', @ConfigID, 
        'Created new system configuration: ' + @ConfigKey,
        @ConfigValue
    );
    
    -- Return the new config ID
    SELECT @ConfigID AS ConfigID;
END
GO

-- Stored procedure to delete system config
CREATE PROCEDURE app.sp_DeleteSystemConfig
    @ConfigKey NVARCHAR(50),
    @DeletedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if config exists
    IF NOT EXISTS (SELECT 1 FROM app.SystemConfig WHERE ConfigKey = @ConfigKey)
    BEGIN
        RAISERROR('Configuration key does not exist', 16, 1);
        RETURN;
    END
    
    -- Check if config is read-only
    DECLARE @IsReadOnly BIT;
    SELECT @IsReadOnly = IsReadOnly FROM app.SystemConfig WHERE ConfigKey = @ConfigKey;
    
    IF @IsReadOnly = 1
    BEGIN
        RAISERROR('Configuration is read-only and cannot be deleted', 16, 1);
        RETURN;
    END
    
    -- Get config data for logging
    DECLARE @ConfigID INT, @ConfigValue NVARCHAR(MAX);
    SELECT 
        @ConfigID = ConfigID,
        @ConfigValue = ConfigValue
    FROM 
        app.SystemConfig 
    WHERE 
        ConfigKey = @ConfigKey;
    
    -- Delete config
    DELETE FROM app.SystemConfig WHERE ConfigKey = @ConfigKey;
    
    -- Log the activity
    INSERT INTO app.ActivityLog (
        AccountID, ActivityType, EntityType, EntityID, Description, OldValue
    )
    VALUES (
        @DeletedBy, 'Delete', 'SystemConfig', @ConfigID, 
        'Deleted system configuration: ' + @ConfigKey,
        @ConfigValue
    );
    
    -- Return success
    SELECT 'Configuration deleted successfully' AS Result;
END
GO

-- Stored procedure to log system event
CREATE PROCEDURE app.sp_LogSystemEvent
    @LogLevel NVARCHAR(20),
    @Message NVARCHAR(MAX),
    @Source NVARCHAR(100) = NULL,
    @Exception NVARCHAR(MAX) = NULL,
    @StackTrace NVARCHAR(MAX) = NULL,
    @AccountID INT = NULL,
    @IPAddress NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO app.SystemLog (
        LogLevel, Message, Source, Exception, StackTrace, AccountID, IPAddress, LogDate
    )
    VALUES (
        @LogLevel, @Message, @Source, @Exception, @StackTrace, @AccountID, @IPAddress, GETDATE()
    );
    
    -- Return the new log ID
    SELECT SCOPE_IDENTITY() AS LogID;
END
GO

-- Stored procedure to get system logs
CREATE PROCEDURE app.sp_GetSystemLogs
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @LogLevel NVARCHAR(20) = NULL,
    @Source NVARCHAR(100) = NULL,
    @AccountID INT = NULL,
    @MaxRows INT = 1000
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP (@MaxRows)
        l.LogID,
        l.LogLevel,
        l.Message,
        l.Source,
        l.Exception,
        l.StackTrace,
        l.AccountID,
        a.Username,
        l.IPAddress,
        l.LogDate
    FROM 
        app.SystemLog l
    LEFT JOIN 
        app.Account a ON l.AccountID = a.AccountID
    WHERE 
        (@StartDate IS NULL OR l.LogDate >= @StartDate)
        AND (@EndDate IS NULL OR l.LogDate <= @EndDate)
        AND (@LogLevel IS NULL OR l.LogLevel = @LogLevel)
        AND (@Source IS NULL OR l.Source LIKE '%' + @Source + '%')
        AND (@AccountID IS NULL OR l.AccountID = @AccountID)
    ORDER BY 
        l.LogDate DESC;
END
GO

-- Stored procedure to get activity logs
CREATE PROCEDURE app.sp_GetActivityLogs
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @ActivityType NVARCHAR(50) = NULL,
    @EntityType NVARCHAR(50) = NULL,
    @AccountID INT = NULL,
    @MaxRows INT = 1000
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP (@MaxRows)
        al.ActivityID,
        al.ActivityType,
        al.EntityType,
        al.EntityID,
        al.Description,
        al.OldValue,
        al.NewValue,
        al.IPAddress,
        al.ActivityDate,
        al.AccountID,
        a.Username,
        e.FullName AS EmployeeName
    FROM 
        app.ActivityLog al
    INNER JOIN 
        app.Account a ON al.AccountID = a.AccountID
    LEFT JOIN 
        app.Employee e ON a.AccountID = e.AccountID
    WHERE 
        (@StartDate IS NULL OR al.ActivityDate >= @StartDate)
        AND (@EndDate IS NULL OR al.ActivityDate <= @EndDate)
        AND (@ActivityType IS NULL OR al.ActivityType = @ActivityType)
        AND (@EntityType IS NULL OR al.EntityType = @EntityType)
        AND (@AccountID IS NULL OR al.AccountID = @AccountID)
    ORDER BY 
        al.ActivityDate DESC;
END
GO

-- Stored procedure to create database backup
CREATE PROCEDURE app.sp_CreateDatabaseBackup
    @BackupPath NVARCHAR(255),
    @BackupName NVARCHAR(100) = NULL,
    @AccountID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Generate backup name if not provided
    IF @BackupName IS NULL
    BEGIN
        SET @BackupName = 'QuanLyCuaHangTienLoi_' + FORMAT(GETDATE(), 'yyyyMMdd_HHmmss');
    END
    
    -- Ensure backup path ends with a backslash
    IF RIGHT(@BackupPath, 1) <> '\'
    BEGIN
        SET @BackupPath = @BackupPath + '\';
    END
    
    -- Full backup path
    DECLARE @FullBackupPath NVARCHAR(500) = @BackupPath + @BackupName + '.bak';
    
    -- Create backup
    DECLARE @SQL NVARCHAR(1000) = 'BACKUP DATABASE [QuanLyCuaHangTienLoi] TO DISK = ''' + @FullBackupPath + ''' WITH COMPRESSION, STATS = 10';
    
    BEGIN TRY
        EXEC sp_executesql @SQL;
        
        -- Get backup size
        DECLARE @BackupSize BIGINT;
        SELECT @BackupSize = size FROM sys.master_files WHERE name = 'QuanLyCuaHangTienLoi';
        
        -- Record backup
        INSERT INTO app.Backup (
            BackupName, BackupPath, BackupSize, BackupDate, AccountID, Status
        )
        VALUES (
            @BackupName, @FullBackupPath, @BackupSize, GETDATE(), @AccountID, 'Success'
        );
        
        -- Log the activity
        INSERT INTO app.ActivityLog (
            AccountID, ActivityType, EntityType, EntityID, Description
        )
        VALUES (
            @AccountID, 'Backup', 'Database', 
            SCOPE_IDENTITY(), 
            'Created database backup: ' + @BackupName
        );
        
        -- Return success
        SELECT 'Database backup created successfully at: ' + @FullBackupPath AS Result;
    END TRY
    BEGIN CATCH
        -- Record failed backup
        INSERT INTO app.Backup (
            BackupName, BackupPath, BackupDate, AccountID, Status, Note
        )
        VALUES (
            @BackupName, @FullBackupPath, GETDATE(), @AccountID, 'Failed', ERROR_MESSAGE()
        );
        
        -- Log the error
        EXEC app.sp_LogSystemEvent 
            @LogLevel = 'Error',
            @Message = 'Database backup failed',
            @Source = 'sp_CreateDatabaseBackup',
            @Exception = ERROR_MESSAGE(),
            @AccountID = @AccountID;
        
        -- Return error
        SELECT 'Database backup failed: ' + ERROR_MESSAGE() AS Result;
    END CATCH
END
GO

PRINT 'System configuration stored procedures created successfully';