USE QuanLyCuaHangTienLoi;
GO

-- Stored procedure to create new import
CREATE PROCEDURE app.sp_CreateImport
    @SupplierID INT,
    @Note NVARCHAR(500) = NULL,
    @EmployeeID INT,
    @ImportItems app.ImportItemType READONLY -- Custom table type for import items
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Generate import code (format: IMP + YYYYMMDD + 4-digit sequence)
        DECLARE @ImportDate DATE = GETDATE();
        DECLARE @DatePart NVARCHAR(8) = FORMAT(@ImportDate, 'yyyyMMdd');
        DECLARE @Sequence INT = 1;
        
        -- Get the last sequence for today
        SELECT @Sequence = ISNULL(MAX(CAST(SUBSTRING(ImportCode, 12, 4) AS INT)), 0) + 1
        FROM app.Import
        WHERE SUBSTRING(ImportCode, 4, 8) = @DatePart;
        
        DECLARE @ImportCode NVARCHAR(20) = 'IMP' + @DatePart + RIGHT('0000' + CAST(@Sequence AS NVARCHAR(4)), 4);
        
        -- Calculate total amount
        DECLARE @TotalAmount DECIMAL(18, 2) = 0;
        SELECT @TotalAmount = SUM(Quantity * UnitPrice)
        FROM @ImportItems;
        
        -- Create import
        INSERT INTO app.Import (
            SupplierID, ImportCode, ImportDate, TotalAmount, 
            Status, Note, CreatedBy, CreatedDate
        )
        VALUES (
            @SupplierID, @ImportCode, GETDATE(), @TotalAmount, 
            'Completed', @Note, @EmployeeID, GETDATE()
        );
        
        -- Get the new import ID
        DECLARE @ImportID INT = SCOPE_IDENTITY();
        
        -- Insert import details and update inventory
        INSERT INTO app.ImportDetail (
            ImportID, ProductID, Quantity, UnitPrice, TotalPrice, ExpiryDate, BatchNumber
        )
        SELECT 
            @ImportID, 
            ProductID, 
            Quantity, 
            UnitPrice, 
            Quantity * UnitPrice,
            ExpiryDate,
            BatchNumber
        FROM 
            @ImportItems;
        
        -- Update inventory and product costs for each product
        DECLARE @ProductID INT, @Quantity INT, @UnitPrice DECIMAL(18, 2), @ExpiryDate DATE, @BatchNumber NVARCHAR(50);
        DECLARE importItems_cursor CURSOR FOR
        SELECT ProductID, Quantity, UnitPrice, ExpiryDate, BatchNumber FROM @ImportItems;
        
        OPEN importItems_cursor;
        FETCH NEXT FROM importItems_cursor INTO @ProductID, @Quantity, @UnitPrice, @ExpiryDate, @BatchNumber;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Get current inventory
            DECLARE @CurrentStock INT;
            SELECT @CurrentStock = Quantity FROM app.Inventory WHERE ProductID = @ProductID;
            
            -- If product doesn't exist in inventory, create it
            IF @@ROWCOUNT = 0
            BEGIN
                INSERT INTO app.Inventory (ProductID, Quantity, LastUpdated)
                VALUES (@ProductID, 0, GETDATE());
                
                SET @CurrentStock = 0;
            END
            
            -- Update inventory
            UPDATE app.Inventory
            SET Quantity = Quantity + @Quantity, LastUpdated = GETDATE()
            WHERE ProductID = @ProductID;
            
            -- Record inventory transaction
            INSERT INTO app.InventoryTransaction (
                ProductID, TransactionType, Quantity, PreviousQuantity, 
                CurrentQuantity, UnitPrice, TotalAmount, 
                ReferenceID, ReferenceType, Note, TransactionDate
            )
            VALUES (
                @ProductID, 'Import', @Quantity, @CurrentStock, 
                @CurrentStock + @Quantity, @UnitPrice, @UnitPrice * @Quantity, 
                @ImportID, 'Import', 
                'Batch: ' + ISNULL(@BatchNumber, 'N/A') + 
                CASE WHEN @ExpiryDate IS NOT NULL THEN ', Expires: ' + CONVERT(NVARCHAR, @ExpiryDate, 103) ELSE '' END, 
                GETDATE()
            );
            
            -- Update product cost price if it has changed
            DECLARE @CurrentCostPrice DECIMAL(18, 2);
            SELECT @CurrentCostPrice = CostPrice FROM app.Product WHERE ProductID = @ProductID;
            
            IF @CurrentCostPrice <> @UnitPrice
            BEGIN
                -- Update product cost price
                UPDATE app.Product
                SET CostPrice = @UnitPrice, ModifiedDate = GETDATE()
                WHERE ProductID = @ProductID;
                
                -- Add to price history
                INSERT INTO app.ProductPrice (
                    ProductID, CostPrice, SellPrice, EffectiveDate, CreatedBy
                )
                SELECT 
                    @ProductID, @UnitPrice, SellPrice, GETDATE(), @EmployeeID
                FROM 
                    app.Product
                WHERE 
                    ProductID = @ProductID;
            END
            
            FETCH NEXT FROM importItems_cursor INTO @ProductID, @Quantity, @UnitPrice, @ExpiryDate, @BatchNumber;
        END
        
        CLOSE importItems_cursor;
        DEALLOCATE importItems_cursor;
        
        -- Log the activity
        INSERT INTO app.ActivityLog (
            AccountID, ActivityType, EntityType, EntityID, Description
        )
        VALUES (
            @EmployeeID, 'Create', 'Import', @ImportID, 
            'Created new import: ' + @ImportCode
        );
        
        COMMIT;
        
        -- Return the new import info
        SELECT 
            @ImportID AS ImportID, 
            @ImportCode AS ImportCode, 
            @TotalAmount AS TotalAmount;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END
GO

-- Create custom table type for import items
CREATE TYPE app.ImportItemType AS TABLE (
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(18, 2),
    ExpiryDate DATE NULL,
    BatchNumber NVARCHAR(50) NULL
);
GO

-- Stored procedure to get import by ID
CREATE PROCEDURE app.sp_GetImportByID
    @ImportID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get import header
    SELECT 
        i.ImportID,
        i.ImportCode,
        i.ImportDate,
        i.TotalAmount,
        i.Status,
        i.Note,
        s.SupplierID,
        s.SupplierName,
        s.ContactPerson,
        s.PhoneNumber AS SupplierPhone,
        e.EmployeeID,
        e.FullName AS EmployeeName
    FROM 
        app.Import i
    INNER JOIN 
        app.Supplier s ON i.SupplierID = s.SupplierID
    INNER JOIN 
        app.Employee e ON i.CreatedBy = e.EmployeeID
    WHERE 
        i.ImportID = @ImportID;
    
    -- Get import details
    SELECT 
        id.ImportDetailID,
        id.ProductID,
        p.ProductName,
        p.ProductCode,
        id.Quantity,
        id.UnitPrice,
        id.TotalPrice,
        id.ExpiryDate,
        id.BatchNumber,
        p.Unit
    FROM 
        app.ImportDetail id
    INNER JOIN 
        app.Product p ON id.ProductID = p.ProductID
    WHERE 
        id.ImportID = @ImportID;
END
GO

-- Stored procedure to get imports by date range
CREATE PROCEDURE app.sp_GetImportsByDateRange
    @StartDate DATE,
    @EndDate DATE,
    @SupplierID INT = NULL,
    @Status NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        i.ImportID,
        i.ImportCode,
        i.ImportDate,
        i.TotalAmount,
        i.Status,
        s.SupplierName,
        e.FullName AS EmployeeName,
        (SELECT COUNT(*) FROM app.ImportDetail WHERE ImportID = i.ImportID) AS ItemCount
    FROM 
        app.Import i
    INNER JOIN 
        app.Supplier s ON i.SupplierID = s.SupplierID
    INNER JOIN 
        app.Employee e ON i.CreatedBy = e.EmployeeID
    WHERE 
        CAST(i.ImportDate AS DATE) BETWEEN @StartDate AND @EndDate
        AND (@SupplierID IS NULL OR i.SupplierID = @SupplierID)
        AND (@Status IS NULL OR i.Status = @Status)
    ORDER BY 
        i.ImportDate DESC;
END
GO

-- Stored procedure to adjust inventory
CREATE PROCEDURE app.sp_AdjustInventory
    @ProductID INT,
    @NewQuantity INT,
    @Reason NVARCHAR(200),
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Get current inventory
        DECLARE @CurrentQuantity INT;
        SELECT @CurrentQuantity = Quantity FROM app.Inventory WHERE ProductID = @ProductID;
        
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Product not found in inventory', 16, 1);
            ROLLBACK;
            RETURN;
        END
        
        -- Calculate adjustment quantity
        DECLARE @AdjustmentQuantity INT = @NewQuantity - @CurrentQuantity;
        
        -- Update inventory
        UPDATE app.Inventory
        SET Quantity = @NewQuantity, LastUpdated = GETDATE()
        WHERE ProductID = @ProductID;
        
        -- Record inventory transaction
        INSERT INTO app.InventoryTransaction (
            ProductID, TransactionType, Quantity, PreviousQuantity, 
            CurrentQuantity, ReferenceType, Note, TransactionDate, CreatedBy
        )
        VALUES (
            @ProductID, 'Adjustment', @AdjustmentQuantity, @CurrentQuantity, 
            @NewQuantity, 'Manual', 'Manual adjustment: ' + @Reason, GETDATE(), @EmployeeID
        );
        
        -- Get product name for logging
        DECLARE @ProductName NVARCHAR(200);
        SELECT @ProductName = ProductName FROM app.Product WHERE ProductID = @ProductID;
        
        -- Log the activity
        INSERT INTO app.ActivityLog (
            AccountID, ActivityType, EntityType, EntityID, Description
        )
        VALUES (
            @EmployeeID, 'Adjust', 'Inventory', @ProductID, 
            'Adjusted inventory for ' + @ProductName + ' from ' + 
            CAST(@CurrentQuantity AS NVARCHAR) + ' to ' + CAST(@NewQuantity AS NVARCHAR) + 
            ' - Reason: ' + @Reason
        );
        
        COMMIT;
        
        -- Return success
        SELECT 'Inventory adjusted successfully' AS Result;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END
GO

-- Stored procedure to get inventory transactions by product
CREATE PROCEDURE app.sp_GetInventoryTransactionsByProduct
    @ProductID INT,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        t.TransactionID,
        t.TransactionType,
        t.Quantity,
        t.PreviousQuantity,
        t.CurrentQuantity,
        t.UnitPrice,
        t.TotalAmount,
        t.ReferenceID,
        t.ReferenceType,
        t.Note,
        t.TransactionDate,
        e.FullName AS CreatedByName
    FROM 
        app.InventoryTransaction t
    LEFT JOIN 
        app.Employee e ON t.CreatedBy = e.EmployeeID
    WHERE 
        t.ProductID = @ProductID
        AND (@StartDate IS NULL OR CAST(t.TransactionDate AS DATE) >= @StartDate)
        AND (@EndDate IS NULL OR CAST(t.TransactionDate AS DATE) <= @EndDate)
    ORDER BY 
        t.TransactionDate DESC;
END
GO

PRINT 'Inventory management stored procedures created successfully';