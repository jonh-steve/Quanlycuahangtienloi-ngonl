USE QuanLyCuaHangTienLoi;
GO

-- Indexes for Account table
CREATE NONCLUSTERED INDEX IX_Account_Username ON app.Account(Username);
CREATE NONCLUSTERED INDEX IX_Account_RoleID ON app.Account(RoleID);
CREATE NONCLUSTERED INDEX IX_Account_IsActive ON app.Account(IsActive);

-- Indexes for Employee table
CREATE NONCLUSTERED INDEX IX_Employee_FullName ON app.Employee(FullName);
CREATE NONCLUSTERED INDEX IX_Employee_PhoneNumber ON app.Employee(PhoneNumber);
CREATE NONCLUSTERED INDEX IX_Employee_AccountID ON app.Employee(AccountID);
CREATE NONCLUSTERED INDEX IX_Employee_IsActive ON app.Employee(IsActive);

-- Indexes for Product table
CREATE NONCLUSTERED INDEX IX_Product_ProductCode ON app.Product(ProductCode);
CREATE NONCLUSTERED INDEX IX_Product_Barcode ON app.Product(Barcode);
CREATE NONCLUSTERED INDEX IX_Product_ProductName ON app.Product(ProductName);
CREATE NONCLUSTERED INDEX IX_Product_CategoryID ON app.Product(CategoryID);
CREATE NONCLUSTERED INDEX IX_Product_IsActive ON app.Product(IsActive);

-- Indexes for Category table
CREATE NONCLUSTERED INDEX IX_Category_CategoryName ON app.Category(CategoryName);
CREATE NONCLUSTERED INDEX IX_Category_ParentCategoryID ON app.Category(ParentCategoryID);
CREATE NONCLUSTERED INDEX IX_Category_IsActive ON app.Category(IsActive);

-- Indexes for Inventory table
CREATE NONCLUSTERED INDEX IX_Inventory_Quantity ON app.Inventory(Quantity);
CREATE NONCLUSTERED INDEX IX_Inventory_LastUpdated ON app.Inventory(LastUpdated);

-- Indexes for Order table
CREATE NONCLUSTERED INDEX IX_Order_OrderCode ON app.Order(OrderCode);
CREATE NONCLUSTERED INDEX IX_Order_OrderDate ON app.Order(OrderDate);
CREATE NONCLUSTERED INDEX IX_Order_CustomerID ON app.Order(CustomerID);
CREATE NONCLUSTERED INDEX IX_Order_EmployeeID ON app.Order(EmployeeID);
CREATE NONCLUSTERED INDEX IX_Order_PaymentMethodID ON app.Order(PaymentMethodID);
CREATE NONCLUSTERED INDEX IX_Order_PaymentStatus ON app.Order(PaymentStatus);

-- Indexes for OrderDetail table
CREATE NONCLUSTERED INDEX IX_OrderDetail_OrderID ON app.OrderDetail(OrderID);
CREATE NONCLUSTERED INDEX IX_OrderDetail_ProductID ON app.OrderDetail(ProductID);
CREATE NONCLUSTERED INDEX IX_OrderDetail_OrderID_ProductID ON app.OrderDetail(OrderID, ProductID);

-- Indexes for Customer table
CREATE NONCLUSTERED INDEX IX_Customer_CustomerName ON app.Customer(CustomerName);
CREATE NONCLUSTERED INDEX IX_Customer_PhoneNumber ON app.Customer(PhoneNumber);
CREATE NONCLUSTERED INDEX IX_Customer_MembershipLevel ON app.Customer(MembershipLevel);

-- Indexes for Supplier table
CREATE NONCLUSTERED INDEX IX_Supplier_SupplierName ON app.Supplier(SupplierName);
CREATE NONCLUSTERED INDEX IX_Supplier_PhoneNumber ON app.Supplier(PhoneNumber);
CREATE NONCLUSTERED INDEX IX_Supplier_IsActive ON app.Supplier(IsActive);

-- Indexes for Import table
CREATE NONCLUSTERED INDEX IX_Import_ImportCode ON app.Import(ImportCode);
CREATE NONCLUSTERED INDEX IX_Import_ImportDate ON app.Import(ImportDate);
CREATE NONCLUSTERED INDEX IX_Import_SupplierID ON app.Import(SupplierID);
CREATE NONCLUSTERED INDEX IX_Import_Status ON app.Import(Status);

-- Indexes for ImportDetail table
CREATE NONCLUSTERED INDEX IX_ImportDetail_ImportID ON app.ImportDetail(ImportID);
CREATE NONCLUSTERED INDEX IX_ImportDetail_ProductID ON app.ImportDetail(ProductID);
CREATE NONCLUSTERED INDEX IX_ImportDetail_ImportID_ProductID ON app.ImportDetail(ImportID, ProductID);

-- Indexes for InventoryTransaction table
CREATE NONCLUSTERED INDEX IX_InventoryTransaction_ProductID ON app.InventoryTransaction(ProductID);
CREATE NONCLUSTERED INDEX IX_InventoryTransaction_TransactionDate ON app.InventoryTransaction(TransactionDate);
CREATE NONCLUSTERED INDEX IX_InventoryTransaction_TransactionType ON app.InventoryTransaction(TransactionType);
CREATE NONCLUSTERED INDEX IX_InventoryTransaction_ReferenceID ON app.InventoryTransaction(ReferenceID);
CREATE NONCLUSTERED INDEX IX_InventoryTransaction_ReferenceType ON app.InventoryTransaction(ReferenceType);

-- Indexes for Expense table
CREATE NONCLUSTERED INDEX IX_Expense_ExpenseTypeID ON app.Expense(ExpenseTypeID);
CREATE NONCLUSTERED INDEX IX_Expense_ExpenseDate ON app.Expense(ExpenseDate);
CREATE NONCLUSTERED INDEX IX_Expense_EmployeeID ON app.Expense(EmployeeID);

-- Indexes for DailySales table
CREATE NONCLUSTERED INDEX IX_DailySales_SalesDate ON app.DailySales(SalesDate);

-- Indexes for ProductSales table
CREATE NONCLUSTERED INDEX IX_ProductSales_ProductID ON app.ProductSales(ProductID);
CREATE NONCLUSTERED INDEX IX_ProductSales_SalesDate ON app.ProductSales(SalesDate);
CREATE NONCLUSTERED INDEX IX_ProductSales_ProductID_SalesDate ON app.ProductSales(ProductID, SalesDate);

-- Indexes for CategorySales table
CREATE NONCLUSTERED INDEX IX_CategorySales_CategoryID ON app.CategorySales(CategoryID);
CREATE NONCLUSTERED INDEX IX_CategorySales_SalesDate ON app.CategorySales(SalesDate);
CREATE NONCLUSTERED INDEX IX_CategorySales_CategoryID_SalesDate ON app.CategorySales(CategoryID, SalesDate);

-- Indexes for SystemLog table
CREATE NONCLUSTERED INDEX IX_SystemLog_LogLevel ON app.SystemLog(LogLevel);
CREATE NONCLUSTERED INDEX IX_SystemLog_LogDate ON app.SystemLog(LogDate);
CREATE NONCLUSTERED INDEX IX_SystemLog_AccountID ON app.SystemLog(AccountID);

-- Indexes for ActivityLog table
CREATE NONCLUSTERED INDEX IX_ActivityLog_AccountID ON app.ActivityLog(AccountID);
CREATE NONCLUSTERED INDEX IX_ActivityLog_ActivityDate ON app.ActivityLog(ActivityDate);
CREATE NONCLUSTERED INDEX IX_ActivityLog_ActivityType ON app.ActivityLog(ActivityType);
CREATE NONCLUSTERED INDEX IX_ActivityLog_EntityType ON app.ActivityLog(EntityType);
CREATE NONCLUSTERED INDEX IX_ActivityLog_EntityID ON app.ActivityLog(EntityID);

-- Indexes for SystemConfig table
CREATE NONCLUSTERED INDEX IX_SystemConfig_ConfigKey ON app.SystemConfig(ConfigKey);

PRINT 'Database indexes created successfully';