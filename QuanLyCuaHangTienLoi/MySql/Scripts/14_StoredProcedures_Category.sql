USE QuanLyCuaHangTienLoi;
GO

-- Stored procedure to get all categories
CREATE PROCEDURE app.sp_GetAllCategories
AS
BEGIN
    SET NOCOUNT ON;
    
    WITH CategoryHierarchy AS (
        -- Root categories (no parent)
        SELECT 
            c.CategoryID,
            c.CategoryName,
            c.Description,
            c.ParentCategoryID,
            c.DisplayOrder,
            c.IsActive,
            0 AS Level,
            CAST(c.CategoryName AS NVARCHAR(500)) AS Hierarchy
        FROM 
            app.Category c
        WHERE 
            c.ParentCategoryID IS NULL
        
        UNION ALL
        
        -- Child categories
        SELECT 
            c.CategoryID,
            c.CategoryName,
            c.Description,
            c.ParentCategoryID,
            c.DisplayOrder,
            c.IsActive,
            ch.Level + 1,
            CAST(ch.Hierarchy + ' > ' + c.CategoryName AS NVARCHAR(500))
        FROM 
            app.Category c
        INNER JOIN 
            CategoryHierarchy ch ON c.ParentCategoryID = ch.CategoryID
    )
    SELECT 
        ch.CategoryID,
        ch.CategoryName,
        ch.Description,
        ch.ParentCategoryID,
        p.CategoryName AS ParentCategoryName,
        ch.DisplayOrder,
        ch.IsActive,
        ch.Level,
        ch.Hierarchy,
        (SELECT COUNT(*) FROM app.Product WHERE CategoryID = ch.CategoryID) AS ProductCount
    FROM 
        CategoryHierarchy ch
    LEFT JOIN 
        app.Category p ON ch.ParentCategoryID = p.CategoryID
    ORDER BY 
        ch.Hierarchy;
END
GO

-- Stored procedure to get category by ID
CREATE PROCEDURE app.sp_GetCategoryByID
    @CategoryID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get category details
    SELECT 
        c.CategoryID,
        c.CategoryName,
        c.Description,
        c.ParentCategoryID,
        p.CategoryName AS ParentCategoryName,
        c.DisplayOrder,
        c.IsActive,
        c.CreatedDate,
        c.ModifiedDate
    FROM 
        app.Category c
    LEFT JOIN 
        app.Category p ON c.ParentCategoryID = p.CategoryID
    WHERE 
        c.CategoryID = @CategoryID;
    
    -- Get child categories
    SELECT 
        CategoryID,
        CategoryName,
        Description,
        DisplayOrder,
        IsActive
    FROM 
        app.Category
    WHERE 
        ParentCategoryID = @CategoryID
    ORDER BY 
        DisplayOrder, CategoryName;
    
    -- Get products in this category
    SELECT 
        p.ProductID,
        p.ProductCode,
        p.ProductName,
        p.SellPrice,
        i.Quantity AS CurrentStock,
        p.IsActive
    FROM 
        app.Product p
    LEFT JOIN 
        app.Inventory i ON p.ProductID = i.ProductID
    WHERE 
        p.CategoryID = @CategoryID
    ORDER BY 
        p.ProductName;
END
GO

-- Stored procedure to create new category
CREATE PROCEDURE app.sp_CreateCategory
    @CategoryName NVARCHAR(100),
    @Description NVARCHAR(500) = NULL,
    @ParentCategoryID INT = NULL,
    @DisplayOrder INT = 0,
    @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if category name already exists
    IF EXISTS (SELECT 1 FROM app.Category WHERE CategoryName = @CategoryName AND (@ParentCategoryID IS NULL OR ParentCategoryID = @ParentCategoryID))
    BEGIN
        RAISERROR('Category name already exists at this level', 16, 1);
        RETURN;
    END
    
    -- Insert new category
    INSERT INTO app.Category (
        CategoryName, Description, ParentCategoryID, DisplayOrder, IsActive, CreatedDate
    )
    VALUES (
        @CategoryName, @Description, @ParentCategoryID, @DisplayOrder, 1, GETDATE()
    );
    
    -- Get the new category ID
    DECLARE @CategoryID INT = SCOPE_IDENTITY();
    
    -- Log the activity
    INSERT INTO app.ActivityLog (
        AccountID, ActivityType, EntityType, EntityID, Description
    )
    VALUES (
        @CreatedBy, 'Create', 'Category', @CategoryID, 
        'Created new category: ' + @CategoryName
    );
    
    -- Return the new category ID
    SELECT @CategoryID AS CategoryID;
END
GO

-- Stored procedure to update category
CREATE PROCEDURE app.sp_UpdateCategory
    @CategoryID INT,
    @CategoryName NVARCHAR(100),
    @Description NVARCHAR(500) = NULL,
    @ParentCategoryID INT = NULL,
    @DisplayOrder INT = 0,
    @IsActive BIT = 1,
    @ModifiedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if category name already exists (excluding current category)
    IF EXISTS (
        SELECT 1 
        FROM app.Category 
        WHERE CategoryName = @CategoryName 
        AND (@ParentCategoryID IS NULL OR ParentCategoryID = @ParentCategoryID)
        AND CategoryID <> @CategoryID
    )
    BEGIN
        RAISERROR('Category name already exists at this level', 16, 1);
        RETURN;
    END
    
    -- Check for circular reference
    IF @ParentCategoryID IS NOT NULL AND @CategoryID = @ParentCategoryID
    BEGIN
        RAISERROR('A category cannot be its own parent', 16, 1);
        RETURN;
    END
    
    -- Get current category data for logging
    DECLARE @OldCategoryName NVARCHAR(100), @OldParentCategoryID INT;
    SELECT 
        @OldCategoryName = CategoryName,
        @OldParentCategoryID = ParentCategoryID
    FROM 
        app.Category 
    WHERE 
        CategoryID = @CategoryID;
    
    -- Update category
    UPDATE app.Category
    SET 
        CategoryName = @CategoryName,
        Description = @Description,
        ParentCategoryID = @ParentCategoryID,
        DisplayOrder = @DisplayOrder,
        IsActive = @IsActive,
        ModifiedDate = GETDATE()
    WHERE 
        CategoryID = @CategoryID;
    
    -- Log the activity
    INSERT INTO app.ActivityLog (
        AccountID, ActivityType, EntityType, EntityID, Description
    )
    VALUES (
        @ModifiedBy, 'Update', 'Category', @CategoryID, 
        'Updated category: ' + @OldCategoryName
    );
    
    -- Return success
    SELECT 'Category updated successfully' AS Result;
END
GO

-- Stored procedure to delete category
CREATE PROCEDURE app.sp_DeleteCategory
    @CategoryID INT,
    @DeletedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Check if category has products
        IF EXISTS (SELECT 1 FROM app.Product WHERE CategoryID = @CategoryID)
        BEGIN
            RAISERROR('Cannot delete category with associated products', 16, 1);
            ROLLBACK;
            RETURN;
        END
        
        -- Check if category has child categories
        IF EXISTS (SELECT 1 FROM app.Category WHERE ParentCategoryID = @CategoryID)
        BEGIN
            RAISERROR('Cannot delete category with child categories', 16, 1);
            ROLLBACK;
            RETURN;
        END
        
        -- Get category name for logging
        DECLARE @CategoryName NVARCHAR(100);
        SELECT @CategoryName = CategoryName FROM app.Category WHERE CategoryID = @CategoryID;
        
        -- Delete category
        DELETE FROM app.Category WHERE CategoryID = @CategoryID;
        
        -- Log the activity
        INSERT INTO app.ActivityLog (
            AccountID, ActivityType, EntityType, EntityID, Description
        )
        VALUES (
            @DeletedBy, 'Delete', 'Category', @CategoryID, 
            'Deleted category: ' + @CategoryName
        );
        
        COMMIT;
        
        -- Return success
        SELECT 'Category deleted successfully' AS Result;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END
GO

PRINT 'Category management stored procedures created successfully';