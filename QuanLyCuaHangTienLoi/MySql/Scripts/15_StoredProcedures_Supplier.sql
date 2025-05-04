USE QuanLyCuaHangTienLoi;
GO

-- Stored procedure to get all suppliers
CREATE PROCEDURE app.sp_GetAllSuppliers
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        s.SupplierID,
        s.SupplierName,
        s.ContactPerson,
        s.PhoneNumber,
        s.Email,
        s.Address,
        s.TaxCode,
        s.IsActive,
        s.CreatedDate,
        s.ModifiedDate,
        (SELECT COUNT(*) FROM app.Import WHERE SupplierID = s.SupplierID) AS ImportCount,
        (SELECT MAX(ImportDate) FROM app.Import WHERE SupplierID = s.SupplierID) AS LastImportDate
    FROM 
        app.Supplier s
    ORDER BY 
        s.SupplierName;
END
GO

-- Stored procedure to get supplier by ID
CREATE PROCEDURE app.sp_GetSupplierByID
    @SupplierID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get supplier details
    SELECT 
        s.SupplierID,
        s.SupplierName,
        s.ContactPerson,
        s.PhoneNumber,
        s.Email,
        s.Address,
        s.TaxCode,
        s.IsActive,
        s.CreatedDate,
        s.ModifiedDate
    FROM 
        app.Supplier s
    WHERE 
        s.SupplierID = @SupplierID;
    
    -- Get recent imports
    SELECT TOP 10
        i.ImportID,
        i.ImportCode,
        i.ImportDate,
        i.TotalAmount,
        i.Status,
        e.FullName AS CreatedByName
    FROM 
        app.Import i
    INNER JOIN 
        app.Employee e ON i.CreatedBy = e.EmployeeID
    WHERE 
        i.SupplierID = @SupplierID
    ORDER BY 
        i.ImportDate DESC;
    
    -- Get products supplied by this supplier
    SELECT DISTINCT
        p.ProductID,
        p.ProductCode,
        p.ProductName,
        c.CategoryName,
        MAX(id.UnitPrice) AS LastUnitPrice,
        MAX(i.ImportDate) AS LastImportDate
    FROM 
        app.ImportDetail id
    INNER JOIN 
        app.Import i ON id.ImportID = i.ImportID
    INNER JOIN 
        app.Product p ON id.ProductID = p.ProductID
    INNER JOIN 
        app.Category c ON p.CategoryID = c.CategoryID
    WHERE 
        i.SupplierID = @SupplierID
    GROUP BY
        p.ProductID, p.ProductCode, p.ProductName, c.CategoryName
    ORDER BY 
        MAX(i.ImportDate) DESC;
END
GO

-- Stored procedure to create new supplier
CREATE PROCEDURE app.sp_CreateSupplier
    @SupplierName NVARCHAR(200),
    @ContactPerson NVARCHAR(100) = NULL,
    @PhoneNumber NVARCHAR(20) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Address NVARCHAR(200) = NULL,
    @TaxCode NVARCHAR(50) = NULL,
    @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if supplier name already exists
    IF EXISTS (SELECT 1 FROM app.Supplier WHERE SupplierName = @SupplierName)
    BEGIN
        RAISERROR('Supplier name already exists', 16, 1);
        RETURN;
    END
    
    -- Insert new supplier
    INSERT INTO app.Supplier (
        SupplierName, ContactPerson, PhoneNumber, Email, Address, TaxCode, IsActive, CreatedDate
    )
    VALUES (
        @SupplierName, @ContactPerson, @PhoneNumber, @Email, @Address, @TaxCode, 1, GETDATE()
    );
    
    -- Get the new supplier ID
    DECLARE @SupplierID INT = SCOPE_IDENTITY();
    
    -- Log the activity
    INSERT INTO app.ActivityLog (
        AccountID, ActivityType, EntityType, EntityID, Description
    )
    VALUES (
        @CreatedBy, 'Create', 'Supplier', @SupplierID, 
        'Created new supplier: ' + @SupplierName
    );
    
    -- Return the new supplier ID
    SELECT @SupplierID AS SupplierID;
END
GO

-- Stored procedure to update supplier
CREATE PROCEDURE app.sp_UpdateSupplier
    @SupplierID INT,
    @SupplierName NVARCHAR(200),
    @ContactPerson NVARCHAR(100) = NULL,
    @PhoneNumber NVARCHAR(20) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Address NVARCHAR(200) = NULL,
    @TaxCode NVARCHAR(50) = NULL,
    @IsActive BIT = 1,
    @ModifiedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if supplier name already exists (excluding current supplier)
    IF EXISTS (
        SELECT 1 
        FROM app.Supplier 
        WHERE SupplierName = @SupplierName 
        AND SupplierID <> @SupplierID
    )
    BEGIN
        RAISERROR('Supplier name already exists', 16, 1);
        RETURN;
    END
    
    -- Get current supplier data for logging
    DECLARE @OldSupplierName NVARCHAR(200);
    SELECT @OldSupplierName = SupplierName FROM app.Supplier WHERE SupplierID = @SupplierID;
    
    -- Update supplier
    UPDATE app.Supplier
    SET 
        SupplierName = @SupplierName,
        ContactPerson = @ContactPerson,
        PhoneNumber = @PhoneNumber,
        Email = @Email,
        Address = @Address,
        TaxCode = @TaxCode,
        IsActive = @IsActive,
        ModifiedDate = GETDATE()
    WHERE 
        SupplierID = @SupplierID;
    
    -- Log the activity
    INSERT INTO app.ActivityLog (
        AccountID, ActivityType, EntityType, EntityID, Description
    )
    VALUES (
        @ModifiedBy, 'Update', 'Supplier', @SupplierID, 
        'Updated supplier: ' + @OldSupplierName
    );
    
    -- Return success
    SELECT 'Supplier updated successfully' AS Result;
END
GO

-- Stored procedure to search suppliers
CREATE PROCEDURE app.sp_SearchSuppliers
    @SearchTerm NVARCHAR(100),
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        s.SupplierID,
        s.SupplierName,
        s.ContactPerson,
        s.PhoneNumber,
        s.Email,
        s.Address,
        s.TaxCode,
        s.IsActive,
        s.CreatedDate,
        s.ModifiedDate,
        (SELECT COUNT(*) FROM app.Import WHERE SupplierID = s.SupplierID) AS ImportCount,
        (SELECT MAX(ImportDate) FROM app.Import WHERE SupplierID = s.SupplierID) AS LastImportDate
    FROM 
        app.Supplier s
    WHERE 
        (
            s.SupplierName LIKE '%' + @SearchTerm + '%' OR
            s.ContactPerson LIKE '%' + @SearchTerm + '%' OR
            s.PhoneNumber LIKE '%' + @SearchTerm + '%' OR
            s.Email LIKE '%' + @SearchTerm + '%' OR
            s.Address LIKE '%' + @SearchTerm + '%' OR
            s.TaxCode LIKE '%' + @SearchTerm + '%'
        )
        AND (@IsActive IS NULL OR s.IsActive = @IsActive)
    ORDER BY 
        s.SupplierName;
END
GO

-- Stored procedure to get supplier product history
CREATE PROCEDURE app.sp_GetSupplierProductHistory
    @SupplierID INT,
    @ProductID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        p.ProductID,
        p.ProductCode,
        p.ProductName,
        i.ImportID,
        i.ImportCode,
        i.ImportDate,
        id.Quantity,
        id.UnitPrice,
        id.TotalPrice,
        id.BatchNumber,
        id.ExpiryDate
    FROM 
        app.ImportDetail id
    INNER JOIN 
        app.Import i ON id.ImportID = i.ImportID
    INNER JOIN 
        app.Product p ON id.ProductID = p.ProductID
    WHERE 
        i.SupplierID = @SupplierID
        AND (@ProductID IS NULL OR id.ProductID = @ProductID)
    ORDER BY 
        i.ImportDate DESC, p.ProductName;
END
GO

PRINT 'Supplier management stored procedures created successfully';