USE QuanLyCuaHangTienLoi;
GO

-- Stored procedure to create full database backup
CREATE PROCEDURE app.sp_CreateFullBackup
    @BackupPath NVARCHAR(255),
    @BackupName NVARCHAR(100) = NULL,
    @AccountID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Generate backup name if not provided
    IF @BackupName IS NULL
    BEGIN
        SET @BackupName = 'QuanLyCuaHangTienLoi_Full_' + FORMAT(GETDATE(), 'yyyyMMdd_HHmmss');
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
            BackupName, BackupPath, BackupSize, BackupDate, AccountID, Status, Note
        )
        VALUES (
            @BackupName, @FullBackupPath, @BackupSize, GETDATE(), @AccountID, 'Success', 'Full backup'
        );
        
        -- Log the activity
        INSERT INTO app.ActivityLog (
            AccountID, ActivityType, EntityType, EntityID, Description
        )
        VALUES (
            @AccountID, 'Backup', 'Database', 
            SCOPE_IDENTITY(), 
            'Created full database backup: ' + @BackupName
        );
        
        -- Return success
        SELECT 'Full database backup created successfully at: ' + @FullBackupPath AS Result;
    END TRY
    BEGIN CATCH
        -- Record failed backup
        INSERT INTO app.Backup (
            BackupName, BackupPath, BackupDate, AccountID, Status, Note
        )
        VALUES (
            @BackupName, @FullBackupPath, GETDATE(), @AccountID, 'Failed', 'Full backup failed: ' + ERROR_MESSAGE()
        );
        
        -- Log the error
        EXEC app.sp_LogSystemEvent 
            @LogLevel = 'Error',
            @Message = 'Full database backup failed',
            @Source = 'sp_CreateFullBackup',
            @Exception = ERROR_MESSAGE(),
            @AccountID = @AccountID;
        
        -- Return error
        SELECT 'Full database backup failed: ' + ERROR_MESSAGE() AS Result;
    END CATCH
END
GO

-- Stored procedure to create differential database backup
CREATE PROCEDURE app.sp_CreateDifferentialBackup
    @BackupPath NVARCHAR(255),
    @BackupName NVARCHAR(100) = NULL,
    @AccountID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Generate backup name if not provided
    IF @BackupName IS NULL
    BEGIN
        SET @BackupName = 'QuanLyCuaHangTienLoi_Diff_' + FORMAT(GETDATE(), 'yyyyMMdd_HHmmss');
    END
    
    -- Ensure backup path ends with a backslash
    IF RIGHT(@BackupPath, 1) <> '\'
    BEGIN
        SET @BackupPath = @BackupPath + '\';
    END
    
    -- Full backup path
    DECLARE @FullBackupPath NVARCHAR(500) = @BackupPath + @BackupName + '.bak';
    
    -- Create differential backup
    DECLARE @SQL NVARCHAR(1000) = 'BACKUP DATABASE [QuanLyCuaHangTienLoi] TO DISK = ''' + @FullBackupPath + ''' WITH DIFFERENTIAL, COMPRESSION, STATS = 10';
    
    BEGIN TRY
        EXEC sp_executesql @SQL;
        
        -- Get backup size
        DECLARE @BackupSize BIGINT;
        SELECT @BackupSize = size FROM sys.master_files WHERE name = 'QuanLyCuaHangTienLoi';
        
        -- Record backup
        INSERT INTO app.Backup (
            BackupName, BackupPath, BackupSize, BackupDate, AccountID, Status, Note
        )
        VALUES (
            @BackupName, @FullBackupPath, @BackupSize, GETDATE(), @AccountID, 'Success', 'Differential backup'
        );
        
        -- Log the activity
        INSERT INTO app.ActivityLog (
            AccountID, ActivityType, EntityType, EntityID, Description
        )
        VALUES (
            @AccountID, 'Backup', 'Database', 
            SCOPE_IDENTITY(), 
            'Created differential database backup: ' + @BackupName
        );
        
        -- Return success
        SELECT 'Differential database backup created successfully at: ' + @FullBackupPath AS Result;
    END TRY
    BEGIN CATCH
        -- Record failed backup
        INSERT INTO app.Backup (
            BackupName, BackupPath, BackupDate, AccountID, Status, Note
        )
        VALUES (
            @BackupName, @FullBackupPath, GETDATE(), @AccountID, 'Failed', 'Differential backup failed: ' + ERROR_MESSAGE()
        );
        
        -- Log the error
        EXEC app.sp_LogSystemEvent 
            @LogLevel = 'Error',
            @Message = 'Differential database backup failed',
            @Source = 'sp_CreateDifferentialBackup',
            @Exception = ERROR_MESSAGE(),
            @AccountID = @AccountID;
        
        -- Return error
        SELECT 'Differential database backup failed: ' + ERROR_MESSAGE() AS Result;
    END CATCH
END
GO

-- Stored procedure to create transaction log backup
CREATE PROCEDURE app.sp_CreateLogBackup
    @BackupPath NVARCHAR(255),
    @BackupName NVARCHAR(100) = NULL,
    @AccountID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Generate backup name if not provided
    IF @BackupName IS NULL
    BEGIN
        SET @BackupName = 'QuanLyCuaHangTienLoi_Log_' + FORMAT(GETDATE(), 'yyyyMMdd_HHmmss');
    END
    
    -- Ensure backup path ends with a backslash
    IF RIGHT(@BackupPath, 1) <> '\'
    BEGIN
        SET @BackupPath = @BackupPath + '\';
    END
    
    -- Full backup path
    DECLARE @FullBackupPath NVARCHAR(500) = @BackupPath + @BackupName + '.trn';
    
    -- Create log backup
    DECLARE @SQL NVARCHAR(1000) = 'BACKUP LOG [QuanLyCuaHangTienLoi] TO DISK = ''' + @FullBackupPath + ''' WITH COMPRESSION, STATS = 10';
    
    BEGIN TRY
        EXEC sp_executesql @SQL;
        
        -- Get backup size (approximate)
        DECLARE @BackupSize BIGINT;
        SELECT @BackupSize = size FROM sys.master_files WHERE name = 'QuanLyCuaHangTienLoi_log';
        
        -- Record backup
        INSERT INTO app.Backup (
            BackupName, BackupPath, BackupSize, BackupDate, AccountID, Status, Note
        )
        VALUES (
            @BackupName, @FullBackupPath, @BackupSize, GETDATE(), @AccountID, 'Success', 'Transaction log backup'
        );
        
        -- Log the activity
        INSERT INTO app.ActivityLog (
            AccountID, ActivityType, EntityType, EntityID, Description
        )
        VALUES (
            @AccountID, 'Backup', 'Database', 
            SCOPE_IDENTITY(), 
            'Created transaction log backup: ' + @BackupName
        );
        
        -- Return success
        SELECT 'Transaction log backup created successfully at: ' + @FullBackupPath AS Result;
    END TRY
    BEGIN CATCH
        -- Record failed backup
        INSERT INTO app.Backup (
            BackupName, BackupPath, BackupDate, AccountID, Status, Note
        )
        VALUES (
            @BackupName, @FullBackupPath, GETDATE(), @AccountID, 'Failed', 'Transaction log backup failed: ' + ERROR_MESSAGE()
        );
        
        -- Log the error
        EXEC app.sp_LogSystemEvent 
            @LogLevel = 'Error',
            @Message = 'Transaction log backup failed',
            @Source = 'sp_CreateLogBackup',
            @Exception = ERROR_MESSAGE(),
            @AccountID = @AccountID;
        
        -- Return error
        SELECT 'Transaction log backup failed: ' + ERROR_MESSAGE() AS Result;
    END CATCH
END
GO

-- Stored procedure to restore database from backup
CREATE PROCEDURE app.sp_RestoreDatabase
    @BackupPath NVARCHAR(500),
    @DataFilePath NVARCHAR(500) = NULL,
    @LogFilePath NVARCHAR(500) = NULL,
    @AccountID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Default data and log file paths if not provided
    IF @DataFilePath IS NULL
    BEGIN
        SELECT @DataFilePath = SUBSTRING(physical_name, 1, LEN(physical_name) - CHARINDEX('\', REVERSE(physical_name)) + 1)
        FROM sys.master_files
        WHERE database_id = DB_ID('QuanLyCuaHangTienLoi') AND type_desc = 'ROWS';
    END
    
    IF @LogFilePath IS NULL
    BEGIN
        SELECT @LogFilePath = SUBSTRING(physical_name, 1, LEN(physical_name) - CHARINDEX('\', REVERSE(physical_name)) + 1)
        FROM sys.master_files
        WHERE database_id = DB_ID('QuanLyCuaHangTienLoi') AND type_desc = 'LOG';
    END
    
    -- Ensure paths end with a backslash
    IF RIGHT(@DataFilePath, 1) <> '\'
    BEGIN
        SET @DataFilePath = @DataFilePath + '\';
    END
    
    IF RIGHT(@LogFilePath, 1) <> '\'
    BEGIN
        SET @LogFilePath = @LogFilePath + '\';
    END
    
    -- Get logical file names from backup
    DECLARE @LogicalDataName NVARCHAR(128), @LogicalLogName NVARCHAR(128);
    DECLARE @FileListTable TABLE (
        LogicalName NVARCHAR(128),
        PhysicalName NVARCHAR(260),
        Type CHAR(1),
        FileGroupName NVARCHAR(128),
        Size NUMERIC(20,0),
        MaxSize NUMERIC(20,0),
        FileID BIGINT,
        CreateLSN NUMERIC(25,0),
        DropLSN NUMERIC(25,0),
        UniqueID UNIQUEIDENTIFIER,
        ReadOnlyLSN NUMERIC(25,0),
        ReadWriteLSN NUMERIC(25,0),
        BackupSizeInBytes BIGINT,
        SourceBlockSize INT,
        FileGroupID INT,
        LogGroupGUID UNIQUEIDENTIFIER,
        DifferentialBaseLSN NUMERIC(25,0),
        DifferentialBaseGUID UNIQUEIDENTIFIER,
        IsReadOnly BIT,
        IsPresent BIT,
        TDEThumbprint VARBINARY(32)
    );
    
    -- Get file list from backup
    DECLARE @FileListSQL NVARCHAR(1000) = 'RESTORE FILELISTONLY FROM DISK = ''' + @BackupPath + '''';
    
    BEGIN TRY
        INSERT INTO @FileListTable
        EXEC sp_executesql @FileListSQL;
        
        -- Get logical file names
        SELECT @LogicalDataName = LogicalName FROM @FileListTable WHERE Type = 'D';
        SELECT @LogicalLogName = LogicalName FROM @FileListTable WHERE Type = 'L';
        
        -- Prepare restore command
        DECLARE @RestoreSQL NVARCHAR(2000) = '
        USE master;
        ALTER DATABASE [QuanLyCuaHangTienLoi] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        RESTORE DATABASE [QuanLyCuaHangTienLoi] FROM DISK = ''' + @BackupPath + '''
        WITH REPLACE,
        MOVE ''' + @LogicalDataName + ''' TO ''' + @DataFilePath + 'QuanLyCuaHangTienLoi.mdf'',
        MOVE ''' + @LogicalLogName + ''' TO ''' + @LogFilePath + 'QuanLyCuaHangTienLoi_log.ldf'',
        STATS = 10;
        ALTER DATABASE [QuanLyCuaHangTienLoi] SET MULTI_USER;';
        
        -- Execute restore
        EXEC sp_executesql @RestoreSQL;
        
        -- Record restore operation
        INSERT INTO app.Backup (
            BackupName, BackupPath, BackupDate, AccountID, Status, Note
        )
        VALUES (
            'Restore_' + FORMAT(GETDATE(), 'yyyyMMdd_HHmmss'),
            @BackupPath, 
            GETDATE(), 
            @AccountID, 
            'Success', 
            'Database restored from backup'
        );
        
        -- Log the activity (this will be in the restored database)
        INSERT INTO app.ActivityLog (
            AccountID, ActivityType, EntityType, EntityID, Description
        )
        VALUES (
            @AccountID, 'Restore', 'Database', 
            SCOPE_IDENTITY(), 
            'Restored database from backup: ' + @BackupPath
        );
        
        -- Return success
        SELECT 'Database restored successfully from: ' + @BackupPath AS Result;
    END TRY
    BEGIN CATCH
        -- Log the error
        EXEC app.sp_LogSystemEvent 
            @LogLevel = 'Error',
            @Message = 'Database restore failed',
            @Source = 'sp_RestoreDatabase',
            @Exception = ERROR_MESSAGE(),
            @AccountID = @AccountID;
        
        -- Return error
        SELECT 'Database restore failed: ' + ERROR_MESSAGE() AS Result;
    END CATCH
END
GO

-- Stored procedure to get backup history
CREATE PROCEDURE app.sp_GetBackupHistory
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @Status NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        b.BackupID,
        b.BackupName,
        b.BackupPath,
        b.BackupSize,
        b.BackupDate,
        b.Status,
        b.Note,
        a.Username AS CreatedBy,
        e.FullName AS EmployeeName
    FROM 
        app.Backup b
    LEFT JOIN 
        app.Account a ON b.AccountID = a.AccountID
    LEFT JOIN 
        app.Employee e ON a.AccountID = e.AccountID
    WHERE 
        (@StartDate IS NULL OR b.BackupDate >= @StartDate)
        AND (@EndDate IS NULL OR b.BackupDate <= @EndDate)
        AND (@Status IS NULL OR b.Status = @Status)
    ORDER BY 
        b.BackupDate DESC;
END
GO

-- Stored procedure to delete old backups
CREATE PROCEDURE app.sp_DeleteOldBackups
    @DaysToKeep INT = 30,
    @AccountID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get list of backups to delete
    DECLARE @BackupsToDelete TABLE (
        BackupID INT,
        BackupPath NVARCHAR(255),
        BackupName NVARCHAR(100)
    );
    
    INSERT INTO @BackupsToDelete
    SELECT 
        BackupID,
        BackupPath,
        BackupName
    FROM 
        app.Backup
    WHERE 
        BackupDate < DATEADD(DAY, -@DaysToKeep, GETDATE());
    
    -- Delete physical backup files
    DECLARE @BackupPath NVARCHAR(255), @BackupName NVARCHAR(100), @BackupID INT;
    DECLARE backup_cursor CURSOR FOR
    SELECT BackupID, BackupPath, BackupName FROM @BackupsToDelete;
    
    OPEN backup_cursor;
    FETCH NEXT FROM backup_cursor INTO @BackupID, @BackupPath, @BackupName;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Try to delete the physical file
        DECLARE @DeleteSQL NVARCHAR(500) = 'EXEC master.dbo.xp_cmdshell ''del "' + @BackupPath + '" /F''';
        
        BEGIN TRY
            EXEC sp_executesql @DeleteSQL;
            
            -- Update backup record
            UPDATE app.Backup
            SET Note = Note + ' | File deleted on ' + CONVERT(NVARCHAR, GETDATE(), 120)
            WHERE BackupID = @BackupID;
        END TRY
        BEGIN CATCH
            -- Log error but continue
            EXEC app.sp_LogSystemEvent 
                @LogLevel = 'Warning',
                @Message = 'Failed to delete backup file',
                @Source = 'sp_DeleteOldBackups',
                @Exception = 'Failed to delete: ' + @BackupPath,
                @AccountID = @AccountID;
        END CATCH
        
        FETCH NEXT FROM backup_cursor INTO @BackupID, @BackupPath, @BackupName;
    END
    
    CLOSE backup_cursor;
    DEALLOCATE backup_cursor;
    
    -- Delete backup records from database
    DELETE FROM app.Backup
    WHERE BackupID IN (SELECT BackupID FROM @BackupsToDelete);
    
    -- Log the activity
    INSERT INTO app.ActivityLog (
        AccountID, ActivityType, EntityType, EntityID, Description
    )
    VALUES (
        @AccountID, 'Maintenance', 'Backup', 
        0, 
        'Deleted ' + CAST((SELECT COUNT(*) FROM @BackupsToDelete) AS NVARCHAR) + ' old backups older than ' + CAST(@DaysToKeep AS NVARCHAR) + ' days'
    );
    
    -- Return result
    SELECT 'Deleted ' + CAST((SELECT COUNT(*) FROM @BackupsToDelete) AS NVARCHAR) + ' old backups' AS Result;
END
GO

PRINT 'Backup and restore procedures created successfully';