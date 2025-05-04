USE QuanLyCuaHangTienLoi;
GO

-- Stored procedure to get daily sales report
CREATE PROCEDURE app.sp_GetDailySalesReport
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get daily sales summary
    SELECT 
        CAST(o.OrderDate AS DATE) AS SalesDate,
        COUNT(DISTINCT o.OrderID) AS OrderCount,
        SUM(o.TotalAmount) AS TotalSales,
        SUM(o.FinalAmount) AS FinalAmount,
        SUM(o.Tax) AS TotalTax
    FROM 
        app.Order o
    WHERE 
        CAST(o.OrderDate AS DATE) BETWEEN @StartDate AND @EndDate
        AND o.PaymentStatus = 'Paid'
    GROUP BY 
        CAST(o.OrderDate AS DATE)
    ORDER BY 
        CAST(o.OrderDate AS DATE);
    
    -- Get product category sales
    SELECT 
        c.CategoryID,
        c.CategoryName,
        COUNT(DISTINCT o.OrderID) AS OrderCount,
        SUM(od.Quantity) AS TotalQuantity,
        SUM(od.TotalPrice) AS TotalSales
    FROM 
        app.OrderDetail od
    INNER JOIN 
        app.Order o ON od.OrderID = o.OrderID
    INNER JOIN 
        app.Product p ON od.ProductID = p.ProductID
    INNER JOIN 
        app.Category c ON p.CategoryID = c.CategoryID
    WHERE 
        CAST(o.OrderDate AS DATE) BETWEEN @StartDate AND @EndDate
        AND o.PaymentStatus = 'Paid'
    GROUP BY 
        c.CategoryID, c.CategoryName
    ORDER BY 
        SUM(od.TotalPrice) DESC;
    
    -- Get payment method summary
    SELECT 
        pm.PaymentMethodID,
        pm.MethodName,
        COUNT(DISTINCT o.OrderID) AS OrderCount,
        SUM(o.FinalAmount) AS TotalAmount
    FROM 
        app.Order o
    INNER JOIN 
        app.PaymentMethod pm ON o.PaymentMethodID = pm.PaymentMethodID
    WHERE 
        CAST(o.OrderDate AS DATE) BETWEEN @StartDate AND @EndDate
        AND o.PaymentStatus = 'Paid'
    GROUP BY 
        pm.PaymentMethodID, pm.MethodName
    ORDER BY 
        SUM(o.FinalAmount) DESC;
END
GO

-- Stored procedure to get top selling products
CREATE PROCEDURE app.sp_GetTopSellingProducts
    @StartDate DATE,
    @EndDate DATE,
    @TopCount INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP (@TopCount)
        p.ProductID,
        p.ProductCode,
        p.ProductName,
        c.CategoryName,
        SUM(od.Quantity) AS TotalQuantity,
        SUM(od.TotalPrice) AS TotalSales,
        COUNT(DISTINCT o.OrderID) AS OrderCount
    FROM 
        app.OrderDetail od
    INNER JOIN 
        app.Order o ON od.OrderID = o.OrderID
    INNER JOIN 
        app.Product p ON od.ProductID = p.ProductID
    INNER JOIN 
        app.Category c ON p.CategoryID = c.CategoryID
    WHERE 
        CAST(o.OrderDate AS DATE) BETWEEN @StartDate AND @EndDate
        AND o.PaymentStatus = 'Paid'
    GROUP BY 
        p.ProductID, p.ProductCode, p.ProductName, c.CategoryName
    ORDER BY 
        SUM(od.Quantity) DESC;
END
GO

-- Stored procedure to get inventory value report
CREATE PROCEDURE app.sp_GetInventoryValueReport
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        c.CategoryName,
        p.ProductID,
        p.ProductCode,
        p.ProductName,
        i.Quantity AS CurrentStock,
        p.CostPrice AS UnitCost,
        p.SellPrice AS UnitPrice,
        (i.Quantity * p.CostPrice) AS TotalCostValue,
        (i.Quantity * p.SellPrice) AS TotalSellValue,
        ((i.Quantity * p.SellPrice) - (i.Quantity * p.CostPrice)) AS PotentialProfit
    FROM 
        app.Product p
    INNER JOIN 
        app.Category c ON p.CategoryID = c.CategoryID
    INNER JOIN 
        app.Inventory i ON p.ProductID = i.ProductID
    WHERE 
        p.IsActive = 1
    ORDER BY 
        c.CategoryName, p.ProductName;
    
    -- Summary by category
    SELECT 
        c.CategoryName,
        COUNT(p.ProductID) AS ProductCount,
        SUM(i.Quantity) AS TotalQuantity,
        SUM(i.Quantity * p.CostPrice) AS TotalCostValue,
        SUM(i.Quantity * p.SellPrice) AS TotalSellValue,
        SUM((i.Quantity * p.SellPrice) - (i.Quantity * p.CostPrice)) AS PotentialProfit
    FROM 
        app.Product p
    INNER JOIN 
        app.Category c ON p.CategoryID = c.CategoryID
    INNER JOIN 
        app.Inventory i ON p.ProductID = i.ProductID
    WHERE 
        p.IsActive = 1
    GROUP BY 
        c.CategoryName
    ORDER BY 
        SUM(i.Quantity * p.CostPrice) DESC;
END
GO

-- Stored procedure to get revenue report by date range
CREATE PROCEDURE app.sp_GetRevenueReport
    @StartDate DATE,
    @EndDate DATE,
    @GroupBy NVARCHAR(10) = 'Day' -- Day, Week, Month
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @GroupBy = 'Day'
    BEGIN
        SELECT 
            CAST(o.OrderDate AS DATE) AS ReportDate,
            COUNT(DISTINCT o.OrderID) AS OrderCount,
            SUM(o.TotalAmount) AS GrossSales,
            SUM(o.Discount) AS TotalDiscount,
            SUM(o.Tax) AS TotalTax,
            SUM(o.FinalAmount) AS NetSales
        FROM 
            app.Order o
        WHERE 
            CAST(o.OrderDate AS DATE) BETWEEN @StartDate AND @EndDate
            AND o.PaymentStatus = 'Paid'
        GROUP BY 
            CAST(o.OrderDate AS DATE)
        ORDER BY 
            CAST(o.OrderDate AS DATE);
    END
    ELSE IF @GroupBy = 'Week'
    BEGIN
        SELECT 
            DATEPART(YEAR, o.OrderDate) AS Year,
            DATEPART(WEEK, o.OrderDate) AS WeekNumber,
            MIN(CAST(o.OrderDate AS DATE)) AS WeekStart,
            COUNT(DISTINCT o.OrderID) AS OrderCount,
            SUM(o.TotalAmount) AS GrossSales,
            SUM(o.Discount) AS TotalDiscount,
            SUM(o.Tax) AS TotalTax,
            SUM(o.FinalAmount) AS NetSales
        FROM 
            app.Order o
        WHERE 
            CAST(o.OrderDate AS DATE) BETWEEN @StartDate AND @EndDate
            AND o.PaymentStatus = 'Paid'
        GROUP BY 
            DATEPART(YEAR, o.OrderDate), DATEPART(WEEK, o.OrderDate)
        ORDER BY 
            DATEPART(YEAR, o.OrderDate), DATEPART(WEEK, o.OrderDate);
    END
    ELSE IF @GroupBy = 'Month'
    BEGIN
        SELECT 
            DATEPART(YEAR, o.OrderDate) AS Year,
            DATEPART(MONTH, o.OrderDate) AS Month,
            DATENAME(MONTH, o.OrderDate) AS MonthName,
            COUNT(DISTINCT o.OrderID) AS OrderCount,
            SUM(o.TotalAmount) AS GrossSales,
            SUM(o.Discount) AS TotalDiscount,
            SUM(o.Tax) AS TotalTax,
            SUM(o.FinalAmount) AS NetSales
        FROM 
            app.Order o
        WHERE 
            CAST(o.OrderDate AS DATE) BETWEEN @StartDate AND @EndDate
            AND o.PaymentStatus = 'Paid'
        GROUP BY 
            DATEPART(YEAR, o.OrderDate), DATEPART(MONTH, o.OrderDate), DATENAME(MONTH, o.OrderDate)
        ORDER BY 
            DATEPART(YEAR, o.OrderDate), DATEPART(MONTH, o.OrderDate);
    END
END
GO

-- Stored procedure to get employee sales performance
CREATE PROCEDURE app.sp_GetEmployeeSalesPerformance
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.EmployeeID,
        e.FullName AS EmployeeName,
        COUNT(DISTINCT o.OrderID) AS OrderCount,
        SUM(o.TotalAmount) AS TotalSales,
        SUM(o.FinalAmount) AS NetSales,
        AVG(o.FinalAmount) AS AverageOrderValue,
        MIN(o.OrderDate) AS FirstOrderDate,
        MAX(o.OrderDate) AS LastOrderDate
    FROM 
        app.Order o
    INNER JOIN 
        app.Employee e ON o.EmployeeID = e.EmployeeID
    WHERE 
        CAST(o.OrderDate AS DATE) BETWEEN @StartDate AND @EndDate
        AND o.PaymentStatus = 'Paid'
    GROUP BY 
        e.EmployeeID, e.FullName
    ORDER BY 
        SUM(o.FinalAmount) DESC;
END
GO

PRINT 'Reporting stored procedures created successfully';