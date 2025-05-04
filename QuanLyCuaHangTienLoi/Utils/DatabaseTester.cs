using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Windows.Forms;

namespace QuanLyCuaHangTienLoi.Utils
{
    public static class DatabaseTester
    {
        // Kiểm tra kết nối đến cơ sở dữ liệu
        public static bool TestConnection(out string errorMessage)
        {
            SqlConnection connection = null;
            errorMessage = string.Empty;

            try
            {
                // Lấy kết nối từ ConnectionManager
                connection = Db.ConnectionManager.GetConnection();
                connection.Open();

                // Kiểm tra nếu kết nối đã mở
                if (connection.State == ConnectionState.Open)
                {
                    Db.Logger.LogInfo("Kết nối cơ sở dữ liệu thành công");
                    return true;
                }
                else
                {
                    errorMessage = "Không thể mở kết nối đến cơ sở dữ liệu";
                    return false;
                }
            }
            catch (SqlException ex)
            {
                Db.Logger.LogException(ex, "Lỗi kết nối đến SQL Server");
                errorMessage = "Lỗi kết nối SQL: " + ex.Message;
                return false;
            }
            catch (Exception ex)
            {
                Db.Logger.LogException(ex, "Lỗi không xác định khi kết nối đến cơ sở dữ liệu");
                errorMessage = "Lỗi: " + ex.Message;
                return false;
            }
            finally
            {
                Db.ConnectionManager.CloseConnection(connection);
            }
        }

        // Kiểm tra cấu trúc cơ sở dữ liệu
        public static bool VerifyDatabaseStructure(out string report)
        {
            StringBuilder sb = new StringBuilder();
            bool success = true;

            try
            {
                // Kiểm tra bảng Account
                if (TableExists("app.Account"))
                {
                    sb.AppendLine("✓ Bảng app.Account tồn tại");
                }
                else
                {
                    sb.AppendLine("✗ Bảng app.Account không tồn tại");
                    success = false;
                }

                // Kiểm tra bảng Role
                if (TableExists("app.Role"))
                {
                    sb.AppendLine("✓ Bảng app.Role tồn tại");
                }
                else
                {
                    sb.AppendLine("✗ Bảng app.Role không tồn tại");
                    success = false;
                }

                // Kiểm tra bảng Product
                if (TableExists("app.Product"))
                {
                    sb.AppendLine("✓ Bảng app.Product tồn tại");
                }
                else
                {
                    sb.AppendLine("✗ Bảng app.Product không tồn tại");
                    success = false;
                }

                // Kiểm tra Stored Procedure
                if (StoredProcedureExists("app.sp_AuthenticateUser"))
                {
                    sb.AppendLine("✓ Stored Procedure app.sp_AuthenticateUser tồn tại");
                }
                else
                {
                    sb.AppendLine("✗ Stored Procedure app.sp_AuthenticateUser không tồn tại");
                    success = false;
                }

                // Kiểm tra dữ liệu mẫu
                if (CheckDefaultData())
                {
                    sb.AppendLine("✓ Dữ liệu mẫu đã được tạo");
                }
                else
                {
                    sb.AppendLine("✗ Dữ liệu mẫu chưa được tạo");
                    success = false;
                }

                // Thêm kết quả chung
                if (success)
                {
                    sb.AppendLine("\n✓ Cơ sở dữ liệu đã được thiết lập đúng cấu trúc");
                }
                else
                {
                    sb.AppendLine("\n✗ Cơ sở dữ liệu chưa được thiết lập đúng cấu trúc");
                    sb.AppendLine("Vui lòng chạy lại script 00_MasterScript.sql để tạo cơ sở dữ liệu");
                }
            }
            catch (Exception ex)
            {
                Db.Logger.LogException(ex, "Lỗi khi kiểm tra cấu trúc cơ sở dữ liệu");

                sb.AppendLine("✗ Lỗi khi kiểm tra cấu trúc cơ sở dữ liệu:");
                sb.AppendLine(ex.Message);
                success = false;
            }

            report = sb.ToString();
            return success;
        }

        // Kiểm tra bảng có tồn tại
        private static bool TableExists(string tableName)
        {
            string query = @"
                SELECT COUNT(*) 
                FROM INFORMATION_SCHEMA.TABLES 
                WHERE TABLE_SCHEMA + '.' + TABLE_NAME = @TableName";

            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@TableName", tableName)
            };

            object result = Db.ConnectionManager.ExecuteScalar(query, CommandType.Text, parameters);
            return Convert.ToInt32(result) > 0;
        }

        // Kiểm tra stored procedure có tồn tại
        private static bool StoredProcedureExists(string procedureName)
        {
            string query = @"
                SELECT COUNT(*) 
                FROM INFORMATION_SCHEMA.ROUTINES 
                WHERE SPECIFIC_SCHEMA + '.' + SPECIFIC_NAME = @ProcedureName 
                AND ROUTINE_TYPE = 'PROCEDURE'";

            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@ProcedureName", procedureName)
            };

            object result = Db.ConnectionManager.ExecuteScalar(query, CommandType.Text, parameters);
            return Convert.ToInt32(result) > 0;
        }

        // Kiểm tra dữ liệu mẫu đã được tạo
        private static bool CheckDefaultData()
        {
            // Kiểm tra tài khoản admin mặc định
            string query = "SELECT COUNT(*) FROM app.Account WHERE Username = 'admin'";
            object result = Db.ConnectionManager.ExecuteScalar(query);
            return Convert.ToInt32(result) > 0;
        }

        // Hiển thị form kiểm tra kết nối
        public static void ShowConnectionTestForm()
        {
            string errorMessage;
            bool isConnected = TestConnection(out errorMessage);

            if (isConnected)
            {
                string report;
                bool validStructure = VerifyDatabaseStructure(out report);

                if (validStructure)
                {
                    MessageBox.Show(
                        "Kết nối cơ sở dữ liệu thành công!\n\n" + report,
                        "Kiểm tra cơ sở dữ liệu",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Information);
                }
                else
                {
                    MessageBox.Show(
                        "Kết nối cơ sở dữ liệu thành công, nhưng cấu trúc chưa đúng!\n\n" + report,
                        "Kiểm tra cơ sở dữ liệu",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Warning);
                }
            }
            else
            {
                MessageBox.Show(
                    "Lỗi kết nối cơ sở dữ liệu!\n\n" + errorMessage +
                    "\n\nVui lòng kiểm tra chuỗi kết nối trong app.config và đảm bảo SQL Server đang chạy.",
                    "Lỗi kết nối",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
        }
    }
}