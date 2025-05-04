USE QuanLyCuaHangTienLoi;
GO

-- Create Supplier table
CREATE TABLE app.Supplier (
    SupplierID INT PRIMARY KEY IDENTITY(1,1),
    SupplierName NVARCHAR(200) NOT NULL,
    ContactPerson NVARCHAR(100),
    PhoneNumber NVARCHAR(20),
    Email NVARCHAR(100),
    Address NVARCHAR(200),
    TaxCode NVARCHAR(50),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME
);

-- Create Inventory table
CREATE TABLE app.Inventory (
    InventoryID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT FOREIGN KEY REFERENCES app.Product(ProductID),
    Quantity INT NOT NULL DEFAULT 0,
    LastUpdated DATETIME DEFAULT GETDATE()
);

-- Create InventoryTransaction table for tracking inventory changes
CREATE TABLE app.InventoryTransaction (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT FOREIGN KEY REFERENCES app.Product(ProductID),
    TransactionType NVARCHAR(20) NOT NULL, -- Import, Export, Adjustment
    Quantity INT NOT NULL,
    PreviousQuantity INT NOT NULL,
    CurrentQuantity INT NOT NULL,
    UnitPrice DECIMAL(18, 2),
    TotalAmount DECIMAL(18, 2),
    ReferenceID INT, -- OrderID or ImportID
    ReferenceType NVARCHAR(20), -- Order, Import
    Note NVARCHAR(200),
    TransactionDate DATETIME DEFAULT GETDATE(),
    CreatedBy INT
);

-- Create Import table for tracking product imports
CREATE TABLE app.Import (
    ImportID INT PRIMARY KEY IDENTITY(1,1),
    SupplierID INT FOREIGN KEY REFERENCES app.Supplier(SupplierID),
    ImportCode NVARCHAR(20) NOT NULL UNIQUE,
    ImportDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(18, 2) NOT NULL DEFAULT 0,
    Status NVARCHAR(20) DEFAULT 'Pending', -- Pending, Completed, Cancelled
    Note NVARCHAR(500),
    CreatedBy INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME
);

-- Create ImportDetail table
CREATE TABLE app.ImportDetail (
    ImportDetailID INT PRIMARY KEY IDENTITY(1,1),
    ImportID INT FOREIGN KEY REFERENCES app.Import(ImportID),
    ProductID INT FOREIGN KEY REFERENCES app.Product(ProductID),
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18, 2) NOT NULL,
    TotalPrice DECIMAL(18, 2) NOT NULL,
    ExpiryDate DATE,
    BatchNumber NVARCHAR(50),
    Note NVARCHAR(200)
);

-- Insert some default suppliers
INSERT INTO app.Supplier (SupplierName, ContactPerson, PhoneNumber, Email, Address)
VALUES 
    (N'Công ty TNHH Thực phẩm ABC', N'Nguyễn Văn A', '0901234567', 'contact@abc.com', N'123 Đường Lê Lợi, Quận 1, TP.HCM'),
    (N'Công ty CP Đồ uống XYZ', N'Trần Thị B', '0912345678', 'info@xyz.com', N'456 Đường Nguyễn Huệ, Quận 1, TP.HCM'),
    (N'Nhà phân phối Hàng tiêu dùng DEF', N'Lê Văn C', '0923456789', 'sales@def.com', N'789 Đường Cách Mạng Tháng 8, Quận 3, TP.HCM');

PRINT 'Supplier and Inventory tables created successfully';