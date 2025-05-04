USE QuanLyCuaHangTienLoi;
GO

-- Stored procedure to get all customers
CREATE PROCEDURE app.sp_GetAllCustomers
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        c.CustomerID,
        c.CustomerName,
        c.PhoneNumber,
        c.Email,
        c.Address,
        c.MembershipLevel,
        c.Points,
        c.CreatedDate,
        c.ModifiedDate,
        (SELECT COUNT(*) FROM app.Order WHERE CustomerID = c.CustomerID) AS OrderCount,
        (SELECT SUM(FinalAmount) FROM app.Order WHERE CustomerID = c.CustomerID AND PaymentStatus = 'Paid') AS TotalSpent,
        (SELECT MAX(OrderDate) FROM app.Order WHERE CustomerID = c.CustomerID) AS LastOrderDate
    FROM 
        app.Customer c
    ORDER BY 
        c.CustomerName;
END
GO

-- Stored procedure to get customer by ID
CREATE PROCEDURE app.sp_GetCustomerByID
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get customer details
    SELECT 
        c.CustomerID,
        c.CustomerName,
        c.PhoneNumber,
        c.Email,
        c.Address,
        c.MembershipLevel,
        c.Points,
        c.CreatedDate,
        c.ModifiedDate
    FROM 
        app.Customer c
    WHERE 
        c.CustomerID = @CustomerID;
    
    -- Get recent orders
    SELECT TOP 10
        o.OrderID,
        o.OrderCode,
        o.OrderDate,
        o.TotalAmount,
        o.Discount,
        o.Tax,
        o.FinalAmount,
        o.PaymentStatus,
        pm.MethodName AS PaymentMethod,
        e.FullName AS EmployeeName,
        (SELECT COUNT(*) FROM app.OrderDetail WHERE OrderID = o.OrderID) AS ItemCount
    FROM 
        app.Order o
    INNER JOIN 
        app.PaymentMethod pm ON o.PaymentMethodID = pm.PaymentMethodID
    INNER JOIN 
        app.Employee e ON o.EmployeeID = e.EmployeeID
    WHERE 
        o.CustomerID = @CustomerID
    ORDER BY 
        o.OrderDate DESC;
    
    -- Get purchase statistics
    SELECT 
        COUNT(DISTINCT o.OrderID) AS TotalOrders,
        SUM(o.FinalAmount) AS TotalSpent,
        AVG(o.FinalAmount) AS AverageOrderValue,
        MIN(o.OrderDate) AS FirstOrderDate,
        MAX(o.OrderDate) AS LastOrderDate,
        DATEDIFF(DAY, MAX(o.OrderDate), GETDATE()) AS DaysSinceLastOrder
    FROM 
        app.Order o
    WHERE 
        o.CustomerID = @CustomerID
        AND o.PaymentStatus = 'Paid';
    
    -- Get top purchased products
    SELECT TOP 5
        p.ProductID,
        p.ProductName,
        SUM(od.Quantity) AS TotalQuantity,
        COUNT(DISTINCT o.OrderID) AS OrderCount
    FROM 
        app.OrderDetail od
    INNER JOIN 
        app.Order o ON od.OrderID = o.OrderID
    INNER JOIN 
        app.Product p ON od.ProductID = p.ProductID
    WHERE 
        o.CustomerID = @CustomerID
        AND o.PaymentStatus = 'Paid'
    GROUP BY 
        p.ProductID, p.ProductName
    ORDER BY 
        SUM(od.Quantity) DESC;
END
GO

-- Stored procedure to create new customer
CREATE PROCEDURE app.sp_CreateCustomer
    @CustomerName NVARCHAR(100),
    @PhoneNumber NVARCHAR(20) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Address NVARCHAR(200) = NULL,
    @MembershipLevel NVARCHAR(20) = 'Regular',
    @Points INT = 0,
    @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if phone number already exists
    IF @PhoneNumber IS NOT NULL AND EXISTS (SELECT 1 FROM app.Customer WHERE PhoneNumber = @PhoneNumber)
    BEGIN
        RAISERROR('Phone number already exists', 16, 1);
        RETURN;
    END
    
    -- Insert new customer
    INSERT INTO app.Customer (
        CustomerName, PhoneNumber, Email, Address, MembershipLevel, Points, CreatedDate
    )
    VALUES (
        @CustomerName, @PhoneNumber, @Email, @Address, @MembershipLevel, @Points, GETDATE()
    );
    
    -- Get the new customer ID
    DECLARE @CustomerID INT = SCOPE_IDENTITY();
    
    -- Log the activity
    INSERT INTO app.ActivityLog (
        AccountID, ActivityType, EntityType, EntityID, Description
    )
    VALUES (
        @CreatedBy, 'Create', 'Customer', @CustomerID, 
        'Created new customer: ' + @CustomerName
    );
    
    -- Return the new customer ID
    SELECT @CustomerID AS CustomerID;
END
GO

-- Stored procedure to update customer
CREATE PROCEDURE app.sp_UpdateCustomer
    @CustomerID INT,
    @CustomerName NVARCHAR(100),
    @PhoneNumber NVARCHAR(20) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Address NVARCHAR(200) = NULL,
    @MembershipLevel NVARCHAR(20) = 'Regular',
    @Points INT = NULL,
    @ModifiedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if phone number already exists (excluding current customer)
    IF @PhoneNumber IS NOT NULL AND EXISTS (
        SELECT 1 
        FROM app.Customer 
        WHERE PhoneNumber = @PhoneNumber 
        AND CustomerID <> @CustomerID
    )
    BEGIN
        RAISERROR('Phone number already exists', 16, 1);
        RETURN;
    END
    
    -- Get current customer data for logging
    DECLARE @OldCustomerName NVARCHAR(100), @OldPoints INT;
    SELECT 
        @OldCustomerName = CustomerName,
        @OldPoints = Points
    FROM 
        app.Customer 
    WHERE 
        CustomerID = @CustomerID;
    
    -- Update customer
    UPDATE app.Customer
    SET 
        CustomerName = @CustomerName,
        PhoneNumber = @PhoneNumber,
        Email = @Email,
        Address = @Address,
        MembershipLevel = @MembershipLevel,
        Points = ISNULL(@Points, Points),
        ModifiedDate = GETDATE()
    WHERE 
        CustomerID = @CustomerID;
    
    -- Log the activity
    INSERT INTO app.ActivityLog (
        AccountID, ActivityType, EntityType, EntityID, Description
    )
    VALUES (
        @ModifiedBy, 'Update', 'Customer', @CustomerID, 
        'Updated customer: ' + @OldCustomerName
    );
    
    -- Return success
    SELECT 'Customer updated successfully' AS Result;
END
GO

-- Stored procedure to search customers
CREATE PROCEDURE app.sp_SearchCustomers
    @SearchTerm NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        c.CustomerID,
        c.CustomerName,
        c.PhoneNumber,
        c.Email,
        c.Address,
        c.MembershipLevel,
        c.Points,
        (SELECT COUNT(*) FROM app.Order WHERE CustomerID = c.CustomerID) AS OrderCount,
        (SELECT SUM(FinalAmount) FROM app.Order WHERE CustomerID = c.CustomerID AND PaymentStatus = 'Paid') AS TotalSpent,
        (SELECT MAX(OrderDate) FROM app.Order WHERE CustomerID = c.CustomerID) AS LastOrderDate
    FROM 
        app.Customer c
    WHERE 
        c.CustomerName LIKE '%' + @SearchTerm + '%' OR
        c.PhoneNumber LIKE '%' + @SearchTerm + '%' OR
        c.Email LIKE '%' + @SearchTerm + '%' OR
        c.Address LIKE '%' + @SearchTerm + '%'
    ORDER BY 
        c.CustomerName;
END
GO

-- Stored procedure to add/subtract customer points
CREATE PROCEDURE app.sp_UpdateCustomerPoints
    @CustomerID INT,
    @PointsChange INT,
    @Reason NVARCHAR(200),
    @ModifiedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get current points
    DECLARE @CurrentPoints INT, @CustomerName NVARCHAR(100);
    SELECT 
        @CurrentPoints = Points,
        @CustomerName = CustomerName
    FROM 
        app.Customer 
    WHERE 
        CustomerID = @CustomerID;
    
    -- Update points
    UPDATE app.Customer
    SET 
        Points = Points + @PointsChange,
        ModifiedDate = GETDATE()
    WHERE 
        CustomerID = @CustomerID;
    
    -- Log the activity
    INSERT INTO app.ActivityLog (
        AccountID, ActivityType, EntityType, EntityID, Description
    )
    VALUES (
        @ModifiedBy, 'Update', 'CustomerPoints', @CustomerID, 
        'Updated points for ' + @CustomerName + ' from ' + 
        CAST(@CurrentPoints AS NVARCHAR) + ' to ' + CAST((@CurrentPoints + @PointsChange) AS NVARCHAR) + 
        ' (' + CASE WHEN @PointsChange > 0 THEN '+' ELSE '' END + CAST(@PointsChange AS NVARCHAR) + ')' +
        ' - Reason: ' + @Reason
    );
    
    -- Return success
    SELECT 'Customer points updated successfully' AS Result;
END
GO

-- Stored procedure to get top customers
CREATE PROCEDURE app.sp_GetTopCustomers
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @TopCount INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP (@TopCount)
        c.CustomerID,
        c.CustomerName,
        c.PhoneNumber,
        c.Email,
        c.MembershipLevel,
        c.Points,
        COUNT(DISTINCT o.OrderID) AS OrderCount,
        SUM(o.FinalAmount) AS TotalSpent,
        AVG(o.FinalAmount) AS AverageOrderValue,
        MAX(o.OrderDate) AS LastOrderDate
    FROM 
        app.Customer c
    INNER JOIN 
        app.Order o ON c.CustomerID = o.CustomerID
    WHERE 
        o.PaymentStatus = 'Paid'
        AND (@StartDate IS NULL OR o.OrderDate >= @StartDate)
        AND (@EndDate IS NULL OR o.OrderDate <= @EndDate)
    GROUP BY 
        c.CustomerID, c.CustomerName, c.PhoneNumber, c.Email, c.MembershipLevel, c.Points
    ORDER BY 
        SUM(o.FinalAmount) DESC;
END
GO

PRINT 'Customer management stored procedures created successfully';