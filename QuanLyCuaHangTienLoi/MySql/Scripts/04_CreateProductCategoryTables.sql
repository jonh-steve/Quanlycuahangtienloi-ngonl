USE QuanLyCuaHangTienLoi;
GO

-- Create Category table
CREATE TABLE app.Category (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    ParentCategoryID INT FOREIGN KEY REFERENCES app.Category(CategoryID),
    DisplayOrder INT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME
);

-- Create Product table
CREATE TABLE app.Product (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductCode NVARCHAR(20) NOT NULL UNIQUE,
    Barcode NVARCHAR(50),
    ProductName NVARCHAR(200) NOT NULL,
    CategoryID INT FOREIGN KEY REFERENCES app.Category(CategoryID),
    Description NVARCHAR(500),
    CostPrice DECIMAL(18, 2) NOT NULL,
    SellPrice DECIMAL(18, 2) NOT NULL,
    Unit NVARCHAR(20),
    ImagePath NVARCHAR(255),
    MinimumStock INT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME
);

-- Create ProductImage table for multiple images per product
CREATE TABLE app.ProductImage (
    ImageID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT FOREIGN KEY REFERENCES app.Product(ProductID),
    ImagePath NVARCHAR(255) NOT NULL,
    DisplayOrder INT DEFAULT 0,
    IsDefault BIT DEFAULT 0,
    CreatedDate DATETIME DEFAULT GETDATE()
);

-- Create ProductPrice table for price history
CREATE TABLE app.ProductPrice (
    PriceID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT FOREIGN KEY REFERENCES app.Product(ProductID),
    CostPrice DECIMAL(18, 2) NOT NULL,
    SellPrice DECIMAL(18, 2) NOT NULL,
    EffectiveDate DATETIME NOT NULL,
    EndDate DATETIME,
    CreatedBy INT,
    CreatedDate DATETIME DEFAULT GETDATE()
);

-- Insert some default categories
INSERT INTO app.Category (CategoryName, Description)
VALUES 
    (N'Đồ uống', N'Nước giải khát, nước đóng chai, sữa...'),
    (N'Thực phẩm', N'Các loại thực phẩm đóng gói'),
    (N'Bánh kẹo', N'Các loại bánh, kẹo, snack'),
    (N'Đồ dùng cá nhân', N'Các sản phẩm chăm sóc cá nhân'),
    (N'Đồ gia dụng', N'Các sản phẩm dùng trong gia đình');

PRINT 'Product and Category tables created successfully';