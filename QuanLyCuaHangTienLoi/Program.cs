using System;
using System.Windows.Forms;
using QuanLyCuaHangTienLoi.Forms.Auth;

namespace QuanLyCuaHangTienLoi
{
    static class Program
    {
        /// <summary>
        /// Điểm khởi đầu của ứng dụng.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            try
            {
                // Khởi động ứng dụng với form đăng nhập
                Application.Run(new LoginForm());
            }
            catch (Exception ex)
            {
                // Ghi log lỗi không xử lý được
                Db.Logger.LogException(ex, "Lỗi không xử lý được trong ứng dụng");

                // Hiển thị thông báo lỗi cho người dùng
                MessageBox.Show(
                    "Đã xảy ra lỗi không mong muốn trong ứng dụng. Vui lòng liên hệ hỗ trợ kỹ thuật.\n\n" +
                    "Chi tiết lỗi: " + ex.Message,
                    "Lỗi ứng dụng",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
        }
    }
}