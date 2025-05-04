using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace QuanLyCuaHangTienLoi.Db
{
    public class ConnectionManager
    {
        private static readonly string _connectionString = ConfigurationManager
            .ConnectionStrings["QuanLyCuaHangTienLoiConnection"].ConnectionString;

        // Tạo và trả về kết nối mới
        public static SqlConnection GetConnection()
        {
            try
            {
                SqlConnection connection = new SqlConnection(_connectionString);
                return connection;
            }
            catch (Exception ex)
            {
                Logger.Log("Lỗi khi tạo kết nối: " + ex.Message, LogLevel.Error);
                throw;
            }
        }

        // Đóng kết nối an toàn
        public static void CloseConnection(SqlConnection connection)
        {
            try
            {
                if (connection != null && connection.State != ConnectionState.Closed)
                {
                    connection.Close();
                    Logger.Log("Đã đóng kết nối DB", LogLevel.Info);
                }
            }
            catch (Exception ex)
            {
                Logger.Log("Lỗi khi đóng kết nối: " + ex.Message, LogLevel.Error);
            }
        }

        // Phương thức thực thi truy vấn không trả về dữ liệu
        public static int ExecuteNonQuery(string commandText, CommandType commandType = CommandType.Text,
                                         SqlParameter[] parameters = null)
        {
            SqlConnection connection = null;
            try
            {
                connection = GetConnection();
                connection.Open();

                SqlCommand command = new SqlCommand(commandText, connection);
                command.CommandType = commandType;

                if (parameters != null)
                {
                    command.Parameters.AddRange(parameters);
                }

                return command.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                Logger.Log("Lỗi khi thực thi truy vấn: " + ex.Message, LogLevel.Error);
                throw;
            }
            finally
            {
                CloseConnection(connection);
            }
        }

        // Phương thức thực thi truy vấn và trả về DataTable
        public static DataTable ExecuteQuery(string commandText, CommandType commandType = CommandType.Text,
                                           SqlParameter[] parameters = null)
        {
            SqlConnection connection = null;
            try
            {
                connection = GetConnection();
                connection.Open();

                SqlCommand command = new SqlCommand(commandText, connection);
                command.CommandType = commandType;

                if (parameters != null)
                {
                    command.Parameters.AddRange(parameters);
                }

                SqlDataAdapter adapter = new SqlDataAdapter(command);
                DataTable dataTable = new DataTable();
                adapter.Fill(dataTable);

                return dataTable;
            }
            catch (Exception ex)
            {
                Logger.Log("Lỗi khi thực thi truy vấn: " + ex.Message, LogLevel.Error);
                throw;
            }
            finally
            {
                CloseConnection(connection);
            }
        }

        // Phương thức thực thi truy vấn và trả về giá trị đầu tiên
        public static object ExecuteScalar(string commandText, CommandType commandType = CommandType.Text,
                                         SqlParameter[] parameters = null)
        {
            SqlConnection connection = null;
            try
            {
                connection = GetConnection();
                connection.Open();

                SqlCommand command = new SqlCommand(commandText, connection);
                command.CommandType = commandType;

                if (parameters != null)
                {
                    command.Parameters.AddRange(parameters);
                }

                return command.ExecuteScalar();
            }
            catch (Exception ex)
            {
                Logger.Log("Lỗi khi thực thi truy vấn: " + ex.Message, LogLevel.Error);
                throw;
            }
            finally
            {
                CloseConnection(connection);
            }
        }
    }
}