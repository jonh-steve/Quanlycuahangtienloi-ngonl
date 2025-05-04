USE QuanLyCuaHangTienLoi;
GO

-- View for product inventory status
CREATE VIEW app.vw_ProductInventory
AS
SELECT 
    p.ProductID,
    p.ProductCode,
    p.Barcode,
    p.ProductName,
    c.CategoryID,
    c.CategoryName,
    p.CostPrice,
    p.SellPrice,
    p.Unit,
    p.MinimumStock,
    i.Quantity AS CurrentStock,
    CASE 
        WHEN i.Quantity <= p.MinimumStock THEN 1
        ELSE 0
    END AS IsLowStock,
    CASE 
        WHEN i.Quantity <= 0 THEN 'Out of Stock'
        WHEN i.Quantity <= p.MinimumStock THEN 'Low Stock'
        ELSE 'In Stock'
    END AS StockStatus,
    p.IsActive,
    i.LastUpdated AS LastStockUpdate
FROM 
    app.Product p
INNER JOIN 
    app.Category c ON p.CategoryID = c.CategoryID
LEFT JOIN 
    app.Inventory i ON p.ProductID = i.ProductID;
GO

-- View for order summary
CREATE VIEW app.vw_OrderSummary
AS
SELECT 
    o.OrderID,
    o.OrderCode,
    o.OrderDate,
    o.TotalAmount,
    o.Discount,
    o.Tax,
    o.FinalAmount,
    o.PaymentStatus,
    pm.MethodName AS PaymentMethod,
    c.CustomerID,
    c.CustomerName,
    c.PhoneNumber AS CustomerPhone,
    e.EmployeeID,
    e.FullName AS EmployeeName,
    (SELECT COUNT(*) FROM app.OrderDetail WHERE OrderID = o.OrderID) AS ItemCount
FROM 
    app.Order o
LEFT JOIN 
    app.Customer c ON o.CustomerID = c.CustomerID
INNER JOIN 
    app.Employee e ON o.EmployeeID = e.EmployeeID
INNER JOIN 
    app.PaymentMethod pm ON o.PaymentMethodID = pm.PaymentMethodID;
GO

-- View for order details with product information
CREATE VIEW app.vw_OrderDetailExtended
AS
SELECT 
    od.OrderDetailID,
    od.OrderID,
    o.OrderCode,
    o.OrderDate,
    od.ProductID,
    p.ProductCode,
    p.ProductName,
    p.Barcode,
    c.CategoryName,
    od.Quantity,
    od.UnitPrice,
    od.Discount,
    od.TotalPrice,
    p.Unit
FROM 
    app.OrderDetail od
INNER JOIN 
    app.Order o ON od.OrderID = o.OrderID
INNER JOIN 
    app.Product p ON od.ProductID = p.ProductID
INNER JOIN 
    app.Category c ON p.CategoryID = c.CategoryID;
GO

-- View for daily sales summary
CREATE VIEW app.vw_DailySalesSummary
AS
SELECT 
    CAST(o.OrderDate AS DATE) AS SalesDate,
    COUNT(DISTINCT o.OrderID) AS OrderCount,
    SUM(o.TotalAmount) AS GrossSales,
    SUM(o.Discount) AS TotalDiscount,
    SUM(o.Tax) AS TotalTax,
    SUM(o.FinalAmount) AS NetSales,
    COUNT(DISTINCT o.CustomerID) AS CustomerCount
FROM 
    app.Order o
WHERE 
    o.PaymentStatus = 'Paid'
GROUP BY 
    CAST(o.OrderDate AS DATE);
GO

-- View for product sales analysis
CREATE VIEW app.vw_ProductSalesAnalysis
AS
SELECT 
    p.ProductID,
    p.ProductCode,
    p.ProductName,
    c.CategoryID,
    c.CategoryName,
    COUNT(DISTINCT od.OrderID) AS OrderCount,
    SUM(od.Quantity) AS TotalQuantitySold,
    SUM(od.TotalPrice) AS TotalSales,
    AVG(od.UnitPrice) AS AverageSellingPrice,
    p.CostPrice AS CurrentCostPrice,
    p.SellPrice AS CurrentSellPrice,
    SUM(od.Quantity * od.UnitPrice) - SUM(od.Quantity * p.CostPrice) AS EstimatedProfit
FROM 
    app.OrderDetail od
INNER JOIN 
    app.Order o ON od.OrderID = o.OrderID
INNER JOIN 
    app.Product p ON od.ProductID = p.ProductID
INNER JOIN 
    app.Category c ON p.CategoryID = c.CategoryID
WHERE 
    o.PaymentStatus = 'Paid'
GROUP BY 
    p.ProductID, p.ProductCode, p.ProductName, c.CategoryID, c.CategoryName, p.CostPrice, p.SellPrice;
GO

-- View for employee information
CREATE VIEW app.vw_EmployeeInfo
AS
SELECT 
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    e.FullName,
    e.Gender,
    e.DateOfBirth,
    e.PhoneNumber,
    e.Address,
    e.IdentityCard,
    e.Position,
    e.HireDate,
    e.Salary,
    e.IsActive,
    a.AccountID,
    a.Username,
    a.Email,
    r.RoleID,
    r.RoleName,
    a.LastLogin,
    a.IsActive AS AccountIsActive
FROM 
    app.Employee e
LEFT JOIN 
    app.Account a ON e.AccountID = a.AccountID
LEFT JOIN 
    app.Role r ON a.RoleID = r.RoleID;
GO

-- View for import summary
CREATE VIEW app.vw_ImportSummary
AS
SELECT 
    i.ImportID,
    i.ImportCode,
    i.ImportDate,
    i.TotalAmount,
    i.Status,
    s.SupplierID,
    s.SupplierName,
    s.ContactPerson,
    s.PhoneNumber AS SupplierPhone,
    e.EmployeeID,
    e.FullName AS EmployeeName,
    (SELECT COUNT(*) FROM app.ImportDetail WHERE ImportID = i.ImportID) AS ItemCount
FROM 
    app.Import i
INNER JOIN 
    app.Supplier s ON i.SupplierID = s.SupplierID
INNER JOIN 
    app.Employee e ON i.CreatedBy = e.EmployeeID;
GO

-- View for inventory transactions
CREATE VIEW app.vw_InventoryTransactions
AS
SELECT 
    t.TransactionID,
    t.ProductID,
    p.ProductCode,
    p.ProductName,
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
    e.EmployeeID,
    e.FullName AS CreatedByName
FROM 
    app.InventoryTransaction t
INNER JOIN 
    app.Product p ON t.ProductID = p.ProductID
LEFT JOIN 
    app.Employee e ON t.CreatedBy = e.EmployeeID;
GO

-- View for system activity log
CREATE VIEW app.vw_ActivityLog
AS
SELECT 
    al.ActivityID,
    al.ActivityType,
    al.EntityType,
    al.EntityID,
    al.Description,
    al.IPAddress,
    al.ActivityDate,
    a.AccountID,
    a.Username,
    e.EmployeeID,
    e.FullName AS EmployeeName
FROM 
    app.ActivityLog al
INNER JOIN 
    app.Account a ON al.AccountID = a.AccountID
LEFT JOIN 
    app.Employee e ON a.AccountID = e.AccountID;
GO

PRINT 'Database views created successfully';