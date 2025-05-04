USE QuanLyCuaHangTienLoi;
GO

-- Create Customer table
CREATE TABLE app.Customer (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    CustomerName NVARCHAR(100),
    PhoneNumber NVARCHAR(20),
    Email NVARCHAR(100),
    Address NVARCHAR(200),
    MembershipLevel NVARCHAR(20) DEFAULT 'Regular', -- Regular, Silver, Gold, etc.
    Points INT DEFAULT 0,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME
);

-- Create PaymentMethod table
CREATE TABLE app.PaymentMethod (
    PaymentMethodID INT PRIMARY KEY IDENTITY(1,1),
    MethodName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(200),
    IsActive BIT DEFAULT 1
);

-- Create Order table
CREATE TABLE app.Order (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    OrderCode NVARCHAR(20) NOT NULL UNIQUE,
    CustomerID INT FOREIGN KEY REFERENCES app.Customer(CustomerID),
    EmployeeID INT FOREIGN KEY REFERENCES app.Employee(EmployeeID),
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(18, 2) NOT NULL DEFAULT 0,
    Discount DECIMAL(18, 2) DEFAULT 0,
    Tax DECIMAL(18, 2) DEFAULT 0,
    FinalAmount DECIMAL(18, 2) NOT NULL DEFAULT 0,
    PaymentMethodID INT FOREIGN KEY REFERENCES app.PaymentMethod(PaymentMethodID),
    PaymentStatus NVARCHAR(20) DEFAULT 'Pending', -- Pending, Paid, Cancelled
    Note NVARCHAR(500),
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME
);

-- Create OrderDetail table
CREATE TABLE app.OrderDetail (
    OrderDetailID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT FOREIGN KEY REFERENCES app.Order(OrderID),
    ProductID INT FOREIGN KEY REFERENCES app.Product(ProductID),
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18, 2) NOT NULL,
    Discount DECIMAL(18, 2) DEFAULT 0,
    TotalPrice DECIMAL(18, 2) NOT NULL,
    Note NVARCHAR(200)
);

-- Create Promotion table
CREATE TABLE app.Promotion (
    PromotionID INT PRIMARY KEY IDENTITY(1,1),
    PromotionName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    DiscountType NVARCHAR(20) NOT NULL, -- Percentage, FixedAmount
    DiscountValue DECIMAL(18, 2) NOT NULL,
    StartDate DATETIME NOT NULL,
    EndDate DATETIME NOT NULL,
    MinimumOrderAmount DECIMAL(18, 2) DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME
);

-- Create PromotionProduct table for product-specific promotions
CREATE TABLE app.PromotionProduct (
    PromotionProductID INT PRIMARY KEY IDENTITY(1,1),
    PromotionID INT FOREIGN KEY REFERENCES app.Promotion(PromotionID),
    ProductID INT FOREIGN KEY REFERENCES app.Product(ProductID),
    CategoryID INT FOREIGN KEY REFERENCES app.Category(CategoryID)
);

-- Insert default payment methods
INSERT INTO app.PaymentMethod (MethodName, Description)
VALUES 
    (N'Tiền mặt', N'Thanh toán bằng tiền mặt'),
    (N'Thẻ ngân hàng', N'Thanh toán bằng thẻ ATM/Visa/Master'),
    (N'Ví điện tử', N'Thanh toán qua ví điện tử (Momo, ZaloPay, ...)'),
    (N'Chuyển khoản', N'Thanh toán bằng chuyển khoản ngân hàng');

PRINT 'Order tables created successfully';