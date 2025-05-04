using System;

namespace QuanLyCuaHangTienLoi.Utils
{
    public static class Constants
    {
        // Thông tin phiên bản
        public const string APP_VERSION = "1.0.0";
        public const string APP_NAME = "Quản lý cửa hàng tiện lợi";
        public const string AUTHOR = "steve - vuthuonghai";

        // Đường dẫn
        public static readonly string APP_DATA_FOLDER =
            Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData) + "\\QuanLyCuaHangTienLoi";
        public static readonly string LOG_FOLDER =
            AppDomain.CurrentDomain.BaseDirectory + "\\Logs";
        public static readonly string REPORTS_FOLDER =
            AppDomain.CurrentDomain.BaseDirectory + "\\Reports";

        // Thông số kết nối DB
        public const string CONNECTION_STRING_NAME = "QuanLyCuaHangTienLoiConnection";
        public const int CONNECTION_TIMEOUT = 30; // seconds

        // Quyền người dùng
        public const string ROLE_ADMIN = "Admin";
        public const string ROLE_MANAGER = "Manager";
        public const string ROLE_CASHIER = "Cashier";
        public const string ROLE_INVENTORY = "Inventory";

        // Thông báo lỗi chung
        public const string ERROR_DB_CONNECTION = "Không thể kết nối đến cơ sở dữ liệu. Vui lòng kiểm tra kết nối.";
        public const string ERROR_AUTHENTICATION = "Tên đăng nhập hoặc mật khẩu không đúng.";
        public const string ERROR_PERMISSION = "Bạn không có quyền thực hiện chức năng này.";

        // Định dạng
        public const string DATE_FORMAT = "dd/MM/yyyy";
        public const string TIME_FORMAT = "HH:mm:ss";
        public const string DATETIME_FORMAT = "dd/MM/yyyy HH:mm:ss";
        public const string CURRENCY_FORMAT = "#,##0.00";

        // Giá trị mặc định
        public const decimal DEFAULT_TAX_RATE = 10; // 10%
        public const int DEFAULT_LOW_STOCK_THRESHOLD = 10;
    }
}