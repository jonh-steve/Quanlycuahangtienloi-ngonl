USE QuanLyCuaHangTienLoi;
GO

-- Create Role table
CREATE TABLE app.Role (
    RoleID INT PRIMARY KEY IDENTITY(1,1),
    RoleName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(200),
    CreatedDate DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);

-- Create Account table
CREATE TABLE app.Account (
    AccountID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(128) NOT NULL,
    PasswordSalt NVARCHAR(128) NOT NULL,
    Email NVARCHAR(100),
    RoleID INT FOREIGN KEY REFERENCES app.Role(RoleID),
    LastLogin DATETIME,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME,
    IsActive BIT DEFAULT 1
);

-- Create AccountSession table for tracking login sessions
CREATE TABLE app.AccountSession (
    SessionID INT PRIMARY KEY IDENTITY(1,1),
    AccountID INT FOREIGN KEY REFERENCES app.Account(AccountID),
    SessionToken NVARCHAR(128) NOT NULL,
    IPAddress NVARCHAR(50),
    LoginTime DATETIME DEFAULT GETDATE(),
    ExpiryTime DATETIME,
    IsActive BIT DEFAULT 1
);

-- Insert default roles
INSERT INTO app.Role (RoleName, Description)
VALUES 
    ('Admin', N'Quản trị viên hệ thống'),
    ('Manager', N'Quản lý cửa hàng'),
    ('Cashier', N'Nhân viên thu ngân'),
    ('Inventory', N'Nhân viên kho');

-- Create default admin account (password: Admin@123)
-- Note: In a real application, you would generate proper salt and hash
INSERT INTO app.Account (Username, PasswordHash, PasswordSalt, Email, RoleID)
VALUES ('admin', 'E1ADC3949BA59ABBE56E057F20F883E', 'ABCDEF123456', 'admin@store.com', 1);

PRINT 'Account tables created successfully';