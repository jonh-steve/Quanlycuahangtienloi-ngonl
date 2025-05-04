using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using QuanLyCuaHangTienLoi.Models.Entities;

namespace QuanLyCuaHangTienLoi.Db.Repositories
{
    public class AccountRepository : BaseRepository
    {
        // Xác thực người dùng
        public Account AuthenticateUser(string username, string passwordHash)
        {
            try
            {
                // Tạo danh sách tham số
                List<SqlParameter> parameters = new List<SqlParameter>();
                parameters.Add(CreateParameter("@Username", username, SqlDbType.NVarChar, 50));
                parameters.Add(CreateParameter("@PasswordHash", passwordHash, SqlDbType.NVarChar, 128));

                // Thực thi stored procedure
                DataTable dataTable = ExecuteStoredProcedure("app.sp_AuthenticateUser", parameters);

                // Kiểm tra kết quả
                if (dataTable.Rows.Count == 0)
                {
                    return null;
                }

                // Tạo đối tượng Account từ kết quả
                DataRow row = dataTable.Rows[0];
                Account account = new Account
                {
                    AccountID = Convert.ToInt32(row["AccountID"]),
                    Username = row["Username"].ToString(),
                    Email = row["Email"] != DBNull.Value ? row["Email"].ToString() : null,
                    RoleID = Convert.ToInt32(row["RoleID"]),
                    RoleName = row["RoleName"].ToString()
                };

                // Cập nhật thời gian đăng nhập cuối
                UpdateLastLogin(account.AccountID);

                return account;
            }
            catch (Exception ex)
            {
                Db.Logger.LogException(ex, $"Lỗi khi xác thực người dùng: {username}");
                throw;
            }
        }

        // Cập nhật thời gian đăng nhập cuối
        private void UpdateLastLogin(int accountID)
        {
            try
            {
                // Tạo câu lệnh SQL
                string sql = "UPDATE app.Account SET LastLogin = GETDATE() WHERE AccountID = @AccountID";

                // Tạo tham số
                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@AccountID", accountID)
                };

                // Thực thi câu lệnh
                ConnectionManager.ExecuteNonQuery(sql, CommandType.Text, parameters);
            }
            catch (Exception ex)
            {
                Db.Logger.LogException(ex, $"Lỗi khi cập nhật thời gian đăng nhập cuối: {accountID}");
                // Không throw exception vì đây chỉ là cập nhật phụ
            }
        }

        // Lấy danh sách tất cả tài khoản
        public List<Account> GetAllAccounts()
        {
            try
            {
                // Thực thi stored procedure không tham số
                DataTable dataTable = ExecuteStoredProcedure("app.sp_GetAllAccounts");

                // Tạo danh sách kết quả
                List<Account> accounts = new List<Account>();

                // Duyệt qua từng dòng kết quả
                foreach (DataRow row in dataTable.Rows)
                {
                    Account account = new Account
                    {
                        AccountID = Convert.ToInt32(row["AccountID"]),
                        Username = row["Username"].ToString(),
                        Email = row["Email"] != DBNull.Value ? row["Email"].ToString() : null,
                        RoleName = row["RoleName"].ToString(),
                        LastLogin = row["LastLogin"] != DBNull.Value ? Convert.ToDateTime(row["LastLogin"]) : (DateTime?)null,
                        CreatedDate = Convert.ToDateTime(row["CreatedDate"]),
                        IsActive = Convert.ToBoolean(row["IsActive"])
                    };

                    accounts.Add(account);
                }

                return accounts;
            }
            catch (Exception ex)
            {
                Db.Logger.LogException(ex, "Lỗi khi lấy danh sách tài khoản");
                throw;
            }
        }

        // Lấy thông tin tài khoản theo ID
        public Account GetAccountByID(int accountID)
        {
            try
            {
                // Tạo câu lệnh SQL
                string sql = @"
                    SELECT a.AccountID, a.Username, a.Email, a.RoleID, r.RoleName, 
                           a.LastLogin, a.CreatedDate, a.ModifiedDate, a.IsActive
                    FROM app.Account a
                    INNER JOIN app.Role r ON a.RoleID = r.RoleID
                    WHERE a.AccountID = @AccountID";

                // Tạo tham số
                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@AccountID", accountID)
                };

                // Thực thi câu lệnh
                DataTable dataTable = ConnectionManager.ExecuteQuery(sql, CommandType.Text, parameters);

                // Kiểm tra kết quả
                if (dataTable.Rows.Count == 0)
                {
                    return null;
                }

                // Tạo đối tượng Account từ kết quả
                DataRow row = dataTable.Rows[0];
                Account account = new Account
                {
                    AccountID = Convert.ToInt32(row["AccountID"]),
                    Username = row["Username"].ToString(),
                    Email = row["Email"] != DBNull.Value ? row["Email"].ToString() : null,
                    RoleID = Convert.ToInt32(row["RoleID"]),
                    RoleName = row["RoleName"].ToString(),
                    LastLogin = row["LastLogin"] != DBNull.Value ? Convert.ToDateTime(row["LastLogin"]) : (DateTime?)null,
                    CreatedDate = Convert.ToDateTime(row["CreatedDate"]),
                    ModifiedDate = row["ModifiedDate"] != DBNull.Value ? Convert.ToDateTime(row["ModifiedDate"]) : (DateTime?)null,
                    IsActive = Convert.ToBoolean(row["IsActive"])
                };

                return account;
            }
            catch (Exception ex)
            {
                Db.Logger.LogException(ex, $"Lỗi khi lấy thông tin tài khoản: {accountID}");
                throw;
            }
        }

        // Lấy danh sách các vai trò (roles)
        public DataTable GetAllRoles()
        {
            try
            {
                // Tạo câu lệnh SQL
                string sql = "SELECT RoleID, RoleName, Description FROM app.Role ORDER BY RoleID";

                // Thực thi câu lệnh
                return ConnectionManager.ExecuteQuery(sql);
            }
            catch (Exception ex)
            {
                Db.Logger.LogException(ex, "Lỗi khi lấy danh sách vai trò");
                throw;
            }
        }

        // Tạo tài khoản mới
        public int CreateAccount(Account account, string passwordHash, string passwordSalt, int createdBy)
        {
            try
            {
                // Tạo danh sách tham số
                List<SqlParameter> parameters = new List<SqlParameter>();
                parameters.Add(CreateParameter("@Username", account.Username, SqlDbType.NVarChar, 50));
                parameters.Add(CreateParameter("@PasswordHash", passwordHash, SqlDbType.NVarChar, 128));
                parameters.Add(CreateParameter("@PasswordSalt", passwordSalt, SqlDbType.NVarChar, 128));
                parameters.Add(CreateParameter("@Email", account.Email, SqlDbType.NVarChar, 100));
                parameters.Add(CreateParameter("@RoleID", account.RoleID, SqlDbType.Int));
                parameters.Add(CreateParameter("@CreatedBy", createdBy, SqlDbType.Int));

                // Thực thi stored procedure
                object result = ExecuteScalarStoredProcedure("app.sp_CreateAccount", parameters);

                // Trả về ID của tài khoản mới
                return Convert.ToInt32(result);
            }
            catch (Exception ex)
            {
                Db.Logger.LogException(ex, $"Lỗi khi tạo tài khoản: {account.Username}");
                throw;
            }
        }

        // Cập nhật thông tin tài khoản
        public bool UpdateAccount(Account account, int modifiedBy)
        {
            try
            {
                // Tạo danh sách tham số
                List<SqlParameter> parameters = new List<SqlParameter>();
                parameters.Add(CreateParameter("@AccountID", account.AccountID, SqlDbType.Int));
                parameters.Add(CreateParameter("@Email", account.Email, SqlDbType.NVarChar, 100));
                parameters.Add(CreateParameter("@RoleID", account.RoleID, SqlDbType.Int));
                parameters.Add(CreateParameter("@IsActive", account.IsActive, SqlDbType.Bit));
                parameters.Add(CreateParameter("@ModifiedBy", modifiedBy, SqlDbType.Int));

                // Thực thi stored procedure
                ExecuteNonQueryStoredProcedure("app.sp_UpdateAccount", parameters);

                return true;
            }
            catch (Exception ex)
            {
                Db.Logger.LogException(ex, $"Lỗi khi cập nhật tài khoản: {account.AccountID}");
                throw;
            }
        }

        // Đổi mật khẩu
        public bool ChangePassword(int accountID, string oldPasswordHash, string newPasswordHash, string newPasswordSalt)
        {
            try
            {
                // Tạo danh sách tham số
                List<SqlParameter> parameters = new List<SqlParameter>();
                parameters.Add(CreateParameter("@AccountID", accountID, SqlDbType.Int));
                parameters.Add(CreateParameter("@OldPasswordHash", oldPasswordHash, SqlDbType.NVarChar, 128));
                parameters.Add(CreateParameter("@NewPasswordHash", newPasswordHash, SqlDbType.NVarChar, 128));
                parameters.Add(CreateParameter("@NewPasswordSalt", newPasswordSalt, SqlDbType.NVarChar, 128));

                // Thực thi stored procedure
                ExecuteNonQueryStoredProcedure("app.sp_ChangePassword", parameters);

                return true;
            }
            catch (Exception ex)
            {
                Db.Logger.LogException(ex, $"Lỗi khi đổi mật khẩu: {accountID}");
                throw;
            }
        }
    }
}