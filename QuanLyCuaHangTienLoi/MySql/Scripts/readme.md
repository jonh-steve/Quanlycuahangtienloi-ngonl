# Hướng dẫn thiết lập cơ sở dữ liệu Quản lý cửa hàng tiện lợi

## Giới thiệu

Đây là bộ scripts SQL để tạo và cấu hình cơ sở dữ liệu cho ứng dụng Quản lý cửa hàng tiện lợi. Bộ scripts này bao gồm tất cả các bảng, stored procedures, views, triggers, và indexes cần thiết cho ứng dụng.

## Yêu cầu hệ thống

- SQL Server 2016 trở lên
- Quyền sysadmin hoặc dbcreator để tạo cơ sở dữ liệu mới
- Ít nhất 100MB dung lượng đĩa trống

## Cách cài đặt

### Phương pháp 1: Sử dụng Master Script

1. Mở SQL Server Management Studio (SSMS)
2. Kết nối đến SQL Server instance của bạn
3. Mở file `00_MasterScript.sql`
4. Thực thi script (nhấn F5 hoặc nút Execute)

Master Script sẽ tự động thực thi tất cả các scripts theo đúng thứ tự.

### Phương pháp 2: Thực thi từng script riêng lẻ

Nếu bạn muốn thực thi từng script riêng lẻ, hãy thực hiện theo thứ tự sau:

1. `01_CreateDatabase.sql` - Tạo cơ sở dữ liệu
2. `02_CreateAccountTables.sql` - Tạo bảng tài khoản
3. `03_CreateEmployeeTables.sql` - Tạo bảng nhân viên
4. `04_CreateProductCategoryTables.sql` - Tạo bảng sản phẩm và danh mục
5. `05_CreateSupplierInventoryTables.sql` - Tạo bảng nhà cung cấp và kho hàng
6. `06_CreateOrderTables.sql` - Tạo bảng đơn hàng
7. `07_CreateReportingTables.sql` - Tạo bảng báo cáo
8. `08_CreateSystemTables.sql` - Tạo bảng hệ thống
9. `09_StoredProcedures_Account.sql` - Tạo stored procedures quản lý tài khoản
10. `10_StoredProcedures_Product.sql` - Tạo stored procedures quản lý sản phẩm
11. `11_StoredProcedures_Order.sql` - Tạo stored procedures quản lý đơn hàng
12. `12_StoredProcedures_Inventory.sql` - Tạo stored procedures quản lý kho hàng
13. `13_StoredProcedures_Reporting.sql` - Tạo stored procedures báo cáo
14. `14_StoredProcedures_Category.sql` - Tạo stored procedures quản lý danh mục
15. `15_StoredProcedures_Supplier.sql` - Tạo stored procedures quản lý nhà cung cấp
16. `16_CreateDatabaseViews.sql` - Tạo views
17. `17_StoredProcedures_Employee.sql` - Tạo stored procedures quản lý nhân viên
18. `18_StoredProcedures_Customer.sql` - Tạo stored procedures quản lý khách hàng
19. `19_StoredProcedures_Expense.sql` - Tạo stored procedures quản lý chi phí
20. `20_StoredProcedures_System.sql` - Tạo stored procedures cấu hình hệ thống
21. `21_CreateDatabaseTriggers.sql` - Tạo triggers
22. `22_CreateDatabaseIndexes.sql` - Tạo indexes
23. `23_BackupRestoreProcedures.sql` - Tạo stored procedures sao lưu và phục hồi

## Thông tin đăng nhập mặc định

Sau khi cài đặt, bạn có thể đăng nhập vào hệ thống bằng tài khoản admin mặc định:

- **Username**: admin
- **Password**: Admin@123

**Lưu ý**: Vì lý do bảo mật, hãy đổi mật khẩu admin ngay sau khi đăng nhập lần đầu.

## Bảo trì cơ sở dữ liệu

### Sao lưu cơ sở dữ liệu

Để sao lưu cơ sở dữ liệu, sử dụng stored procedure sau:

```sql
EXEC app.sp_CreateFullBackup 
    @BackupPath = 'C:\Backups', 
    @BackupName = 'QuanLyCuaHangTienLoi_Backup', 
    @AccountID = 1;
```

### Phục hồi cơ sở dữ liệu

Để phục hồi cơ sở dữ liệu từ bản sao lưu, sử dụng stored procedure sau:

```sql
EXEC app.sp_RestoreDatabase 
    @BackupPath = 'C:\Backups\QuanLyCuaHangTienLoi_Backup.bak', 
    @AccountID = 1;
```

### Xóa bản sao lưu cũ

Để xóa các bản sao lưu cũ (mặc định là các bản sao lưu cũ hơn 30 ngày):

```sql
EXEC app.sp_DeleteOldBackups 
    @DaysToKeep = 30, 
    @AccountID = 1;
```

## Cấu trúc cơ sở dữ liệu

Cơ sở dữ liệu được tổ chức thành các nhóm bảng chính sau:

1. **Quản lý tài khoản và nhân viên**: Role, Account, Employee
2. **Quản lý sản phẩm**: Category, Product, ProductPrice, ProductImage
3. **Quản lý kho hàng**: Inventory, InventoryTransaction, Import, ImportDetail
4. **Quản lý đơn hàng**: Customer, Order, OrderDetail, PaymentMethod
5. **Quản lý nhà cung cấp**: Supplier
6. **Báo cáo và thống kê**: DailySales, ProductSales, CategorySales, Expense
7. **Cấu hình hệ thống**: SystemConfig, SystemLog, ActivityLog, Backup

## Hỗ trợ

Nếu bạn gặp vấn đề trong quá trình cài đặt hoặc sử dụng cơ sở dữ liệu, vui lòng liên hệ với đội ngũ hỗ trợ kỹ thuật.