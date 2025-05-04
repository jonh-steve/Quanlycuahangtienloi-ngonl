USE QuanLyCuaHangTienLoi;
GO

-- Create SystemConfig table
CREATE TABLE app.SystemConfig (
    ConfigID INT PRIMARY KEY IDENTITY(1,1),
    ConfigKey NVARCHAR(50) NOT NULL UNIQUE,
    ConfigValue NVARCHAR(MAX),
    Description NVARCHAR(200),
    DataType NVARCHAR(20), -- String, Number, Boolean, DateTime
    IsReadOnly BIT DEFAULT 0,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME
);

-- Create SystemLog table
CREATE TABLE app.SystemLog (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    LogLevel NVARCHAR(20) NOT NULL, -- Info, Warning, Error, Debug
    Message NVARCHAR(MAX) NOT NULL,
    Source NVARCHAR(100),
    Exception NVARCHAR(MAX),
    StackTrace NVARCHAR(MAX),
    AccountID INT,
    IPAddress NVARCHAR(50),
    LogDate DATETIME DEFAULT GETDATE()
);

-- Create ActivityLog table
CREATE TABLE app.ActivityLog (
    ActivityID INT PRIMARY KEY IDENTITY(1,1),
    AccountID INT FOREIGN KEY REFERENCES app.Account(AccountID),
    ActivityType NVARCHAR(50) NOT NULL, -- Login, Logout, Create, Update, Delete, etc.
    EntityType NVARCHAR(50), -- Product, Order, Customer, etc.
    EntityID INT,
    Description NVARCHAR(500),
    OldValue NVARCHAR(MAX),
    NewValue NVARCHAR(MAX),
    IPAddress NVARCHAR(50),
    ActivityDate DATETIME DEFAULT GETDATE()
);

-- Create Backup table
CREATE TABLE app.Backup (
    BackupID INT PRIMARY KEY IDENTITY(1,1),
    BackupName NVARCHAR(100) NOT NULL,
    BackupPath NVARCHAR(255) NOT NULL,
    BackupSize BIGINT,
    BackupDate DATETIME DEFAULT GETDATE(),
    AccountID INT FOREIGN KEY REFERENCES app.Account(AccountID),
    Status NVARCHAR(20), -- Success, Failed
    Note NVARCHAR(500)
);

-- Insert default system configurations
INSERT INTO app.SystemConfig (ConfigKey, ConfigValue, Description, DataType)
VALUES 
    ('StoreName', N'Cửa hàng tiện lợi XYZ', N'Tên cửa hàng', 'String'),
    ('StoreAddress', N'123 Đường ABC, Quận 1, TP.HCM', N'Địa chỉ cửa hàng', 'String'),
    ('StorePhone', '0901234567', N'Số điện thoại cửa hàng', 'String'),
    ('StoreEmail', 'contact@store.com', N'Email cửa hàng', 'String'),
    ('TaxRate', '10', N'Thuế suất (%)', 'Number'),
    ('WorkingHours', '7:00 - 22:00', N'Giờ làm việc', 'String'),
    ('ReceiptFooter', N'Cảm ơn quý khách đã mua hàng!', N'Chân trang hóa đơn', 'String'),
    ('LowStockThreshold', '10', N'Ngưỡng cảnh báo hàng tồn kho thấp', 'Number'),
    ('EnableEmailNotifications', 'true', N'Bật thông báo qua email', 'Boolean'),
    ('BackupFrequency', 'Daily', N'Tần suất sao lưu dữ liệu', 'String');

PRINT 'System tables created successfully';