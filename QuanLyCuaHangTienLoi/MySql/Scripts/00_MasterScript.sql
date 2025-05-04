-- Master Script for QuanLyCuaHangTienLoi Database
-- This script will execute all database creation scripts in the correct order

PRINT '===== STARTING DATABASE CREATION PROCESS =====';
PRINT 'Execution time: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '';

-- Step 1: Create Database
PRINT 'Step 1: Creating Database...';
:r "01_CreateDatabase.sql"
PRINT 'Database created successfully.';
PRINT '';

-- Step 2: Create Account Tables
PRINT 'Step 2: Creating Account Tables...';
:r "02_CreateAccountTables.sql"
PRINT 'Account tables created successfully.';
PRINT '';

-- Step 3: Create Employee Tables
PRINT 'Step 3: Creating Employee Tables...';
:r "03_CreateEmployeeTables.sql"
PRINT 'Employee tables created successfully.';
PRINT '';

-- Step 4: Create Product and Category Tables
PRINT 'Step 4: Creating Product and Category Tables...';
:r "04_CreateProductCategoryTables.sql"
PRINT 'Product and Category tables created successfully.';
PRINT '';

-- Step 5: Create Supplier and Inventory Tables
PRINT 'Step 5: Creating Supplier and Inventory Tables...';
:r "05_CreateSupplierInventoryTables.sql"
PRINT 'Supplier and Inventory tables created successfully.';
PRINT '';

-- Step 6: Create Order Tables
PRINT 'Step 6: Creating Order Tables...';
:r "06_CreateOrderTables.sql"
PRINT 'Order tables created successfully.';
PRINT '';

-- Step 7: Create Reporting Tables
PRINT 'Step 7: Creating Reporting Tables...';
:r "07_CreateReportingTables.sql"
PRINT 'Reporting tables created successfully.';
PRINT '';

-- Step 8: Create System Tables
PRINT 'Step 8: Creating System Tables...';
:r "08_CreateSystemTables.sql"
PRINT 'System tables created successfully.';
PRINT '';

-- Step 9: Create Account Management Stored Procedures
PRINT 'Step 9: Creating Account Management Stored Procedures...';
:r "09_StoredProcedures_Account.sql"
PRINT 'Account management stored procedures created successfully.';
PRINT '';

-- Step 10: Create Product Management Stored Procedures
PRINT 'Step 10: Creating Product Management Stored Procedures...';
:r "10_StoredProcedures_Product.sql"
PRINT 'Product management stored procedures created successfully.';
PRINT '';

-- Step 11: Create Order Management Stored Procedures
PRINT 'Step 11: Creating Order Management Stored Procedures...';
:r "11_StoredProcedures_Order.sql"
PRINT 'Order management stored procedures created successfully.';
PRINT '';

-- Step 12: Create Inventory Management Stored Procedures
PRINT 'Step 12: Creating Inventory Management Stored Procedures...';
:r "12_StoredProcedures_Inventory.sql"
PRINT 'Inventory management stored procedures created successfully.';
PRINT '';

-- Step 13: Create Reporting Stored Procedures
PRINT 'Step 13: Creating Reporting Stored Procedures...';
:r "13_StoredProcedures_Reporting.sql"
PRINT 'Reporting stored procedures created successfully.';
PRINT '';

-- Step 14: Create Category Management Stored Procedures
PRINT 'Step 14: Creating Category Management Stored Procedures...';
:r "14_StoredProcedures_Category.sql"
PRINT 'Category management stored procedures created successfully.';
PRINT '';

-- Step 15: Create Supplier Management Stored Procedures
PRINT 'Step 15: Creating Supplier Management Stored Procedures...';
:r "15_StoredProcedures_Supplier.sql"
PRINT 'Supplier management stored procedures created successfully.';
PRINT '';

-- Step 16: Create Database Views
PRINT 'Step 16: Creating Database Views...';
:r "16_CreateDatabaseViews.sql"
PRINT 'Database views created successfully.';
PRINT '';

-- Step 17: Create Employee Managsement Stored Procedures
PRINT 'Step 17: Creating Employee Management Stored Procedures...';
:r "17_StoredProcedures_Employee.sql"
PRINT 'Employee management stored procedures created successfully.';
PRINT '';



-- Step 19: Create Expense Management Stored Procedures
PRINT 'Step 19: Creating Expense Management Stored Procedures...';
:r "19_StoredProcedures_Expense.sql"
PRINT 'Expense management stored procedures created successfully.';
PRINT '';

-- Step 20: Create System Configuration Stored Procedures
PRINT 'Step 20: Creating System Configuration Stored Procedures...';
:r "20_StoredProcedures_System.sql"
PRINT 'System configuration stored procedures created successfully.';
PRINT '';

-- Step 21: Create Database Triggers
PRINT 'Step 21: Creating Database Triggers...';
:r "21_CreateDatabaseTriggers.sql"
PRINT 'Database triggers created successfully.';
PRINT '';

-- Step 22: Create Database Indexes
PRINT 'Step 22: Creating Database Indexes...';
:r "22_CreateDatabaseIndexes.sql"
PRINT 'Database indexes created successfully.';
PRINT '';

-- Step 23: Create Backup and Restore Procedures
PRINT 'Step 23: Creating Backup and Restore Procedures...';
:r "23_BackupRestoreProcedures.sql"
PRINT 'Backup and restore procedures created successfully.';
PRINT '';

PRINT '===== DATABASE CREATION COMPLETED SUCCESSFULLY =====';
PRINT 'Completion time: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '';
PRINT 'The QuanLyCuaHangTienLoi database has been created and is ready to use.';
PRINT 'Default admin account: username = admin, password = Admin@123';
PRINT '';
PRINT 'Please make sure to change the default admin password after first login.';