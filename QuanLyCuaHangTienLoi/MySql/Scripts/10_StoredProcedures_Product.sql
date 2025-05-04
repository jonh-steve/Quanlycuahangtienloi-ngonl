USE QuanLyCuaHangTienLoi;
GO

-- Stored procedure to get all products with category information
CREATE PROCEDURE app.sp_GetAllProducts
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        p.ProductID,
        p.ProductCode,
        p.Barcode,
        p.ProductName,
        p.Description,
        p.CostPrice,
        p.SellPrice,
        p.Unit,
        p.ImagePath,
        p.MinimumStock,
        p.IsActive,
        c.CategoryID,
        c.CategoryName,
        i.Quantity AS CurrentStock,
        CASE 
            WHEN i.Quantity <= p.MinimumStock THEN 1
            ELSE 0
        END AS IsLowStock
    FROM 
        app.Product p
    INNER JOIN 
        app.Category c ON p.CategoryID = c.CategoryID
    LEFT JOIN 
        app.Inventory i ON p.ProductID = i.ProductID
    ORDER BY 
        p.ProductName;
END
GO

-- Stored procedure to get product by ID
CREATE PROCEDURE app.sp_GetProductByID
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        p.ProductID,
        p.ProductCode,
        p.Barcode,
        p.ProductName,
        p.Description,
        p.CostPrice,
        p.SellPrice,
        p.Unit,
        p.ImagePath,
        p.MinimumStock,
        p.IsActive,
        c.CategoryID,
        c.CategoryName,
        i.Quantity AS CurrentStock
    FROM 
        app.Product p
    INNER JOIN 
        app.Category c ON p.CategoryID = c.CategoryID
    LEFT JOIN 
        app.Inventory i ON p.ProductID = i.ProductID
    WHERE 
        p.ProductID = @ProductID;
        
    -- Get product images
    SELECT 
        ImageID,
        ImagePath,
        DisplayOrder,
        IsDefault
    FROM 
        app.ProductImage
    WHERE 
        ProductID = @ProductID
    ORDER BY 
        DisplayOrder;
        
    -- Get price history
    SELECT 
        PriceID,
        CostPrice,
        SellPrice,
        EffectiveDate,
        EndDate
    FROM 
        app.ProductPrice
    WHERE 
        ProductID = @ProductID
    ORDER BY 
        EffectiveDate DESC;
END
GO

-- Stored procedure to create new product
CREATE PROCEDURE app.sp_CreateProduct
    @ProductCode NVARCHAR(20),
    @Barcode NVARCHAR(50),
    @ProductName NVARCHAR(200),
    @CategoryID INT,
    @Description NVARCHAR(500),
    @CostPrice DECIMAL(18, 2),
    @SellPrice DECIMAL(18, 2),
    @Unit NVARCHAR(20),
    @ImagePath NVARCHAR(255),
    @MinimumStock INT,
    @InitialStock INT,
    @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Check if product code already exists
        IF EXISTS (SELECT 1 FROM app.Product WHERE ProductCode = @ProductCode)
        BEGIN
            RAISERROR('Product code already exists', 16, 1);
            ROLLBACK;
            RETURN;
        END
        
        -- Insert new product
        INSERT INTO app.Product (
            ProductCode, Barcode, ProductName, CategoryID, Description, 
            CostPrice, SellPrice, Unit, ImagePath, MinimumStock, IsActive, CreatedDate
        )
        VALUES (
            @ProductCode, @Barcode, @ProductName, @CategoryID, @Description, 
            @CostPrice, @SellPrice, @Unit, @ImagePath, @MinimumStock, 1, GETDATE()
        );
        
        -- Get the new product ID
        DECLARE @ProductID INT = SCOPE_IDENTITY();
        
        -- Insert initial price history
        INSERT INTO app.ProductPrice (ProductID, CostPrice, SellPrice, EffectiveDate, CreatedBy)
        VALUES (@ProductID, @CostPrice, @SellPrice, GETDATE(), @CreatedBy);
        
        -- Create inventory record
        INSERT INTO app.Inventory (ProductID, Quantity, LastUpdated)
        VALUES (@ProductID, @InitialStock, GETDATE());
        
        -- If initial stock > 0, create inventory transaction
        IF @InitialStock > 0
        BEGIN
            INSERT INTO app.InventoryTransaction (
                ProductID, TransactionType, Quantity, PreviousQuantity, 
                CurrentQuantity, UnitPrice, TotalAmount, 
                ReferenceType, Note, CreatedBy
            )
            VALUES (
                @ProductID, 'Initial', @InitialStock, 0, 
                @InitialStock, @CostPrice, @CostPrice * @InitialStock, 
                'Creation', 'Initial inventory', @CreatedBy
            );
        END
        
        -- Log the activity
        INSERT INTO app.ActivityLog (
            AccountID, ActivityType, EntityType, EntityID, Description
        )
        VALUES (
            @CreatedBy, 'Create', 'Product', @ProductID, 
            'Created new product: ' + @ProductName
        );
        
        COMMIT;
        
        -- Return the new product ID
        SELECT @ProductID AS ProductID;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END
GO

-- Stored procedure to update product
CREATE PROCEDURE app.sp_UpdateProduct
    @ProductID INT,
    @ProductName NVARCHAR(200),
    @CategoryID INT,
    @Description NVARCHAR(500),
    @CostPrice DECIMAL(18, 2),
    @SellPrice DECIMAL(18, 2),
    @Unit NVARCHAR(20),
    @ImagePath NVARCHAR(255),
    @MinimumStock INT,
    @IsActive BIT,
    @ModifiedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Get current product data
        DECLARE @OldCostPrice DECIMAL(18, 2), @OldSellPrice DECIMAL(18, 2), @OldProductName NVARCHAR(200);
        SELECT 
            @OldCostPrice = CostPrice, 
            @OldSellPrice = SellPrice,
            @OldProductName = ProductName
        FROM 
            app.Product 
        WHERE 
            ProductID = @ProductID;
        
        -- Update product
        UPDATE app.Product
        SET 
            ProductName = @ProductName,
            CategoryID = @CategoryID,
            Description = @Description,
            CostPrice = @CostPrice,
            SellPrice = @SellPrice,
            Unit = @Unit,
            ImagePath = CASE WHEN @ImagePath = '' THEN ImagePath ELSE @ImagePath END,
            MinimumStock = @MinimumStock,
            IsActive = @IsActive,
            ModifiedDate = GETDATE()
        WHERE 
            ProductID = @ProductID;
        
        -- If price changed, add to price history
        IF (@OldCostPrice <> @CostPrice OR @OldSellPrice <> @SellPrice)
        BEGIN
            -- End the previous price period
            UPDATE app.ProductPrice
            SET EndDate = GETDATE()
            WHERE ProductID = @ProductID AND EndDate IS NULL;
            
            -- Insert new price record
            INSERT INTO app.ProductPrice (ProductID, CostPrice, SellPrice, EffectiveDate, CreatedBy)
            VALUES (@ProductID, @CostPrice, @SellPrice, GETDATE(), @ModifiedBy);
        END
        
        -- Log the activity
        INSERT INTO app.ActivityLog (
            AccountID, ActivityType, EntityType, EntityID, Description
        )
        VALUES (
            @ModifiedBy, 'Update', 'Product', @ProductID, 
            'Updated product: ' + @OldProductName
        );
        
        COMMIT;
        
        -- Return success
        SELECT 'Product updated successfully' AS Result;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END
GO

-- Stored procedure to search products
CREATE PROCEDURE app.sp_SearchProducts
    @SearchTerm NVARCHAR(100),
    @CategoryID INT = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        p.ProductID,
        p.ProductCode,
        p.Barcode,
        p.ProductName,
        p.Description,
        p.CostPrice,
        p.SellPrice,
        p.Unit,
        p.ImagePath,
        p.MinimumStock,
        p.IsActive,
        c.CategoryID,
        c.CategoryName,
        i.Quantity AS CurrentStock,
        CASE 
            WHEN i.Quantity <= p.MinimumStock THEN 1
            ELSE 0
        END AS IsLowStock
    FROM 
        app.Product p
    INNER JOIN 
        app.Category c ON p.CategoryID = c.CategoryID
    LEFT JOIN 
        app.Inventory i ON p.ProductID = i.ProductID
    WHERE 
        (
            p.ProductName LIKE '%' + @SearchTerm + '%' OR
            p.ProductCode LIKE '%' + @SearchTerm + '%' OR
            p.Barcode LIKE '%' + @SearchTerm + '%' OR
            p.Description LIKE '%' + @SearchTerm + '%'
        )
        AND (@CategoryID IS NULL OR p.CategoryID = @CategoryID)
        AND (@IsActive IS NULL OR p.IsActive = @IsActive)
    ORDER BY 
        p.ProductName;
END
GO

-- Stored procedure to get low stock products
CREATE PROCEDURE app.sp_GetLowStockProducts
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        p.ProductID,
        p.ProductCode,
        p.ProductName,
        p.MinimumStock,
        i.Quantity AS CurrentStock,
        p.MinimumStock - i.Quantity AS ShortageAmount,
        c.CategoryName
    FROM 
        app.Product p
    INNER JOIN 
        app.Category c ON p.CategoryID = c.CategoryID
    INNER JOIN 
        app.Inventory i ON p.ProductID = i.ProductID
    WHERE 
        i.Quantity <= p.MinimumStock
        AND p.IsActive = 1
    ORDER BY 
        (p.MinimumStock - i.Quantity) DESC;
END
GO

PRINT 'Product management stored procedures created successfully';