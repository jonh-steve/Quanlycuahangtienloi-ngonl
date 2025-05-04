```

/quanlycuahangtienloi
  /Db
    ConnectionManager.cs - Quản lý kết nối đến SQL Server
    BaseRepository.cs - Lớp cơ sở cho các repository
    Logger.cs - Hỗ trợ ghi log
    /Repositories
      AccountRepository.cs - Quản lý tài khoản người dùng
      ProductRepository.cs - Quản lý sản phẩm
      CategoryRepository.cs - Quản lý danh mục sản 
      EmployeeRepository.cs - Quản lý nhân viên
      OrderRepository.cs - Quản lý đơn hàng
      OrderDetailRepository.cs - Quản lý chi tiết đơn hàng
      SupplierRepository.cs - Quản lý nhà cung cấp
      InventoryRepository.cs - Quản lý kho hàng
  
  /Models
    /Entities
      Account.cs - Đối tượng tài khoản
      Product.cs - Đối tượng sản phẩm
      Category.cs - Đối tượng danh mục
      Employee.cs - Đối tượng nhân viên
      Order.cs - Đối tượng đơn hàng
      OrderDetail.cs - Đối tượng chi tiết đơn hàng
      Supplier.cs - Đối tượng nhà cung cấp
      Inventory.cs - Đối tượng kho hàng
    /DTO
      AccountDTO.cs - DTO cho tài khoản
      ProductDTO.cs - DTO cho sản phẩm
      CategoryDTO.cs - DTO cho danh mục
      EmployeeDTO.cs - DTO cho nhân viên
      OrderDTO.cs - DTO cho đơn hàng
      OrderDetailDTO.cs - DTO cho chi tiết đơn hàng
      SupplierDTO.cs - DTO cho nhà cung cấp
      InventoryDTO.cs - DTO cho kho hàng
  
  /Services
    AccountService.cs - Xử lý nghiệp vụ liên quan đến tài khoản
    ProductService.cs - Xử lý nghiệp vụ liên quan đến sản phẩm
    CategoryService.cs - Xử lý nghiệp vụ liên quan đến danh mục
    EmployeeService.cs - Xử lý nghiệp vụ liên quan đến nhân viên
    OrderService.cs - Xử lý nghiệp vụ liên quan đến đơn hàng
    SupplierService.cs - Xử lý nghiệp vụ liên quan đến nhà cung cấp
    InventoryService.cs - Xử lý nghiệp vụ liên quan đến kho hàng
    ReportService.cs - Xử lý báo cáo thống kê
  
  /Utils
    Constants.cs - Các hằng số sử dụng trong ứng dụng
    Helpers.cs - Các hàm tiện ích
    Extensions.cs - Các phương thức mở rộng
    Validators.cs - Các hàm kiểm tra dữ liệu
    Security.cs - Các hàm bảo mật (mã hóa, giải mã)
  
  /Forms
    /Auth
      LoginForm.cs - Form đăng nhập
      ChangePasswordForm.cs - Form đổi mật khẩu
    /Admin
      UserManagementForm.cs - Form quản lý người dùng
      SystemConfigForm.cs - Form cấu hình hệ thống
    /Products
      ProductListForm.cs - Form danh sách sản phẩm
      ProductDetailForm.cs - Form chi tiết sản phẩm
      CategoryManagementForm.cs - Form quản lý danh mục
    /Orders
      OrderListForm.cs - Form danh sách đơn hàng
      OrderDetailForm.cs - Form chi tiết đơn hàng
      CreateOrderForm.cs - Form tạo đơn hàng mới
    /Inventory
      InventoryListForm.cs - Form danh sách kho hàng
      InventoryDetailForm.cs - Form chi tiết kho hàng
      ImportProductForm.cs - Form nhập hàng
    /Reports
      SalesReportForm.cs - Form báo cáo doanh số
      InventoryReportForm.cs - Form báo cáo tồn kho
      RevenueReportForm.cs - Form báo cáo doanh thu
  
  /Resources
    /Images - Thư mục chứa hình ảnh
    /Icons - Thư mục chứa biểu tượng
    /Fonts - Thư mục chứa font chữ
    /Localization - Thư mục chứa file ngôn ngữ
  
  /Config
    AppSettings.cs - Cấu hình ứng dụng
    app.config - File cấu hình XML
  
  Program.cs - Điểm khởi đầu của ứng dụng
  MainForm.cs - Form chính của ứng dụng
  ```

  # Quản lý cửa hàng tiện lợi