USE QuanLyCuaHangTienLoi;
GO

-- Create DailySales table for sales reporting
CREATE TABLE app.DailySales (
    DailySalesID INT PRIMARY KEY IDENTITY(1,1),
    SalesDate DATE NOT NULL,
    TotalOrders INT NOT NULL DEFAULT 0,
    TotalSales DECIMAL(18, 2) NOT NULL DEFAULT 0,
    TotalCost DECIMAL(18, 2) NOT NULL DEFAULT 0,
    GrossProfit DECIMAL(18, 2) NOT NULL DEFAULT 0,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME
);

-- Create ProductSales table for product-specific sales reporting
CREATE TABLE app.ProductSales (
    ProductSalesID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT FOREIGN KEY REFERENCES app.Product(ProductID),
    SalesDate DATE NOT NULL,
    QuantitySold INT NOT NULL DEFAULT 0,
    TotalSales DECIMAL(18, 2) NOT NULL DEFAULT 0,
    TotalCost DECIMAL(18, 2) NOT NULL DEFAULT 0,
    Profit DECIMAL(18, 2) NOT NULL DEFAULT 0,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME
);

-- Create CategorySales table for category-specific sales reporting
CREATE TABLE app.CategorySales (
    CategorySalesID INT PRIMARY KEY IDENTITY(1,1),
    CategoryID INT FOREIGN KEY REFERENCES app.Category(CategoryID),
    SalesDate DATE NOT NULL,
    QuantitySold INT NOT NULL DEFAULT 0,
    TotalSales DECIMAL(18, 2) NOT NULL DEFAULT 0,
    TotalCost DECIMAL(18, 2) NOT NULL DEFAULT 0,
    Profit DECIMAL(18, 2) NOT NULL DEFAULT 0,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME
);

-- Create ExpenseType table
CREATE TABLE app.ExpenseType (
    ExpenseTypeID INT PRIMARY KEY IDENTITY(1,1),
    TypeName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(200),
    IsActive BIT DEFAULT 1
);

-- Create Expense table for tracking expenses
CREATE TABLE app.Expense (
    ExpenseID INT PRIMARY KEY IDENTITY(1,1),
    ExpenseTypeID INT FOREIGN KEY REFERENCES app.ExpenseType(ExpenseTypeID),
    Amount DECIMAL(18, 2) NOT NULL,
    ExpenseDate DATE NOT NULL,
    Description NVARCHAR(500),
    EmployeeID INT FOREIGN KEY REFERENCES app.Employee(EmployeeID),
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME
);

-- Insert default expense types
INSERT INTO app.ExpenseType (TypeName, Description)
VALUES 
    (N'Tiền thuê mặt bằng', N'Chi phí thuê cửa hàng'),
    (N'Tiền điện', N'Chi phí điện hàng tháng'),
    (N'Tiền nước', N'Chi phí nước hàng tháng'),
    (N'Lương nhân viên', N'Chi phí lương nhân viên'),
    (N'Vận chuyển', N'Chi phí vận chuyển hàng hóa'),
    (N'Khác', N'Các chi phí khác');

PRINT 'Reporting tables created successfully';