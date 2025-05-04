using System;
using System.IO;
using System.Text;
using System.Security.Cryptography;
using System.Windows.Forms;

namespace QuanLyCuaHangTienLoi.Utils
{
    public static class Helpers
    {
        // Mã hóa mật khẩu sử dụng SHA256
        public static string HashPassword(string password)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] hashedBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));

                StringBuilder builder = new StringBuilder();
                for (int i = 0; i < hashedBytes.Length; i++)
                {
                    builder.Append(hashedBytes[i].ToString("x2"));
                }

                return builder.ToString();
            }
        }

        // Tạo mã ngẫu nhiên
        public static string GenerateRandomCode(int length)
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            StringBuilder builder = new StringBuilder();
            Random random = new Random();

            for (int i = 0; i < length; i++)
            {
                builder.Append(chars[random.Next(chars.Length)]);
            }

            return builder.ToString();
        }

        // Định dạng số tiền
        public static string FormatCurrency(decimal amount)
        {
            return string.Format("{0:#,##0.00} VNĐ", amount);
        }

        // Hiển thị thông báo lỗi
        public static void ShowError(string message, string title = "Lỗi")
        {
            MessageBox.Show(message, title, MessageBoxButtons.OK, MessageBoxIcon.Error);
            Db.Logger.LogError(message);
        }

        // Hiển thị thông báo cảnh báo
        public static void ShowWarning(string message, string title = "Cảnh báo")
        {
            MessageBox.Show(message, title, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            Db.Logger.LogWarning(message);
        }

        // Hiển thị thông báo thông tin
        public static void ShowInfo(string message, string title = "Thông báo")
        {
            MessageBox.Show(message, title, MessageBoxButtons.OK, MessageBoxIcon.Information);
            Db.Logger.LogInfo(message);
        }

        // Hiển thị hộp thoại xác nhận
        public static bool Confirm(string message, string title = "Xác nhận")
        {
            DialogResult result = MessageBox.Show(
                message, title, MessageBoxButtons.YesNo, MessageBoxIcon.Question);

            return result == DialogResult.Yes;
        }

        // Tạo thư mục nếu chưa tồn tại
        public static void EnsureDirectoryExists(string path)
        {
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
        }

        // Kiểm tra kết nối internet
        public static bool IsInternetConnected()
        {
            try
            {
                using (var client = new System.Net.WebClient())
                using (client.OpenRead("http://www.google.com"))
                {
                    return true;
                }
            }
            catch
            {
                return false;
            }
        }

        // Chuyển đổi từ DataTable sang CSV
        public static string DataTableToCSV(System.Data.DataTable dataTable, bool includeHeaders = true)
        {
            StringBuilder sb = new StringBuilder();

            // Thêm header
            if (includeHeaders)
            {
                for (int i = 0; i < dataTable.Columns.Count; i++)
                {
                    sb.Append(dataTable.Columns[i].ColumnName);
                    if (i < dataTable.Columns.Count - 1)
                    {
                        sb.Append(",");
                    }
                }
                sb.AppendLine();
            }

            // Thêm dữ liệu
            foreach (System.Data.DataRow row in dataTable.Rows)
            {
                for (int i = 0; i < dataTable.Columns.Count; i++)
                {
                    if (!Convert.IsDBNull(row[i]))
                    {
                        string value = row[i].ToString();
                        // Nếu giá trị có dấu phẩy, đặt nó trong dấu ngoặc kép
                        if (value.Contains(","))
                        {
                            value = string.Format("\"{0}\"", value);
                        }
                        sb.Append(value);
                    }

                    if (i < dataTable.Columns.Count - 1)
                    {
                        sb.Append(",");
                    }
                }
                sb.AppendLine();
            }

            return sb.ToString();
        }
    }
}