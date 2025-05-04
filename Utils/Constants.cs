namespace QuanLyCuaHangTienLoi.Utils
{
    public static class Constants
    {
        // Roles
        public const string ROLE_ADMIN = "Admin";
        public const string ROLE_MANAGER = "Manager";
        public const string ROLE_CASHIER = "Cashier";
        public const string ROLE_INVENTORY = "Inventory";
        
        // Activity Types
        public const string ACTIVITY_CREATE = "Create";
        public const string ACTIVITY_UPDATE = "Update";
        public const string ACTIVITY_DELETE = "Delete";
        public const string ACTIVITY_LOGIN = "Login";
        public const string ACTIVITY_LOGOUT = "Logout";
        
        // Entity Types
        public const string ENTITY_PRODUCT = "Product";
        public const string ENTITY_CATEGORY = "Category";
        public const string ENTITY_CUSTOMER = "Customer";
        public const string ENTITY_ORDER = "Order";
        public const string ENTITY_SUPPLIER = "Supplier";
        public const string ENTITY_EMPLOYEE = "Employee";
        public const string ENTITY_ACCOUNT = "Account";
        
        // Order Status
        public const string ORDER_COMPLETED = "Completed";
        public const string ORDER_CANCELLED = "Cancelled";
        public const string ORDER_REFUNDED = "Refunded";
        
        // Import Status
        public const string IMPORT_PENDING = "Pending";
        public const string IMPORT_COMPLETED = "Completed";
        public const string IMPORT_CANCELLED = "Cancelled";
        
        // Transaction Types
        public const string TRANSACTION_IMPORT = "Import";
        public const string TRANSACTION_SALE = "Sale";
        public const string TRANSACTION_RETURN = "Return";
        public const string TRANSACTION_ADJUSTMENT = "Adjustment";
        
        // Log Levels
        public const string LOG_INFO = "Info";
        public const string LOG_WARNING = "Warning";
        public const string LOG_ERROR = "Error";
        public const string LOG_CRITICAL = "Critical";
        
        // Config Groups
        public const string CONFIG_SYSTEM = "System";
        public const string CONFIG_SALES = "Sales";
        public const string CONFIG_INVENTORY = "Inventory";
        public const string CONFIG_CUSTOMER = "Customer";
        
        // Common Config Keys
        public const string CONFIG_STORE_NAME = "StoreName";
        public const string CONFIG_STORE_ADDRESS = "StoreAddress";
        public const string CONFIG_STORE_PHONE = "StorePhone";
        public const string CONFIG_STORE_EMAIL = "StoreEmail";
        public const string CONFIG_TAX_RATE = "TaxRate";
        public const string CONFIG_LOW_STOCK_THRESHOLD = "LowStockThreshold";
        public const string CONFIG_BACKUP_PATH = "BackupPath";
        
        // File Paths
        public const string PATH_PRODUCT_IMAGES = "Images/Products";
        public const string PATH_BACKUP = "Backup";
        public const string PATH_REPORTS = "Reports";
        
        // Date Formats
        public const string DATE_FORMAT = "dd/MM/yyyy";
        public const string DATE_TIME_FORMAT = "dd/MM/yyyy HH:mm:ss";
        
        // Pagination
        public const int DEFAULT_PAGE_SIZE = 20;
    }
}