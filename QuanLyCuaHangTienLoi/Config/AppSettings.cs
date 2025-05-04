using System;
using System.Configuration;

namespace QuanLyCuaHangTienLoi.Config
{
    public class AppSettings
    {
        // Thông tin cửa hàng
        public static string StoreName => GetSetting("StoreName", "Cửa hàng tiện lợi XYZ");
        public static string StoreAddress => GetSetting("StoreAddress", "123 Đường ABC, Quận 1, TP.HCM");
        public static string StorePhone => GetSetting("StorePhone", "0901234567");
        public static string StoreEmail => GetSetting("StoreEmail", "contact@store.com");

        // Cài đặt hệ thống
        public static decimal TaxRate => decimal.Parse(GetSetting("TaxRate", "10"));
        public static string WorkingHours => GetSetting("WorkingHours", "7:00 - 22:00");
        public static string ReceiptFooter => GetSetting("ReceiptFooter", "Cảm ơn quý khách đã mua hàng!");
        public static int LowStockThreshold => int.Parse(GetSetting("LowStockThreshold", "10"));

        // Cài đặt khác
        public static bool EnableEmailNotifications => bool.Parse(GetSetting("EnableEmailNotifications", "false"));
        public static string BackupFrequency => GetSetting("BackupFrequency", "Daily");
        public static string BackupPath => GetSetting("BackupPath", AppDomain.CurrentDomain.BaseDirectory + "\\Backups");

        // Phương thức đọc cài đặt từ app.config
        private static string GetSetting(string key, string defaultValue)
        {
            string value = ConfigurationManager.AppSettings[key];
            return string.IsNullOrEmpty(value) ? defaultValue : value;
        }

        // Phương thức cập nhật cài đặt
        public static void UpdateSetting(string key, string value)
        {
            try
            {
                // Lấy configuration hiện tại
                Configuration config = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

                // Cập nhật giá trị
                if (config.AppSettings.Settings[key] != null)
                {
                    config.AppSettings.Settings[key].Value = value;
                }
                else
                {
                    config.AppSettings.Settings.Add(key, value);
                }

                // Lưu thay đổi
                config.Save(ConfigurationSaveMode.Modified);
                ConfigurationManager.RefreshSection("appSettings");

                Db.Logger.LogInfo($"Đã cập nhật cài đặt: {key} = {value}");
            }
            catch (Exception ex)
            {
                Db.Logger.LogException(ex, $"Lỗi khi cập nhật cài đặt: {key}");
                throw;
            }
        }
    }
}