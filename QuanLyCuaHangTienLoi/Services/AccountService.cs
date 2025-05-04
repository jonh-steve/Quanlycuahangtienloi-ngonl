using System;
using System.Data;
using System.Collections.Generic;
using QuanLyCuaHangTienLoi.Db.Repositories;
using QuanLyCuaHangTienLoi.Models.Entities;

namespace QuanLyCuaHangTienLoi.Services
{
    public class AccountService
    {
        private readonly AccountRepository _accountRepository;

        // Constructor
        public AccountService()
        {
            _accountRepository = new AccountRepository();
        }

        // Biến lưu thông tin người dùng đăng nhập hiện tại
        private static Account _currentAccount;

        // Thuộc tính truy cập người dùng hiện tại
        public static Account CurrentAccount
        {
            get { return _currentAccount; }
        }

        // Đăng nhập
        public Account Login(string username, string password)
        {
            try
            {
                // Kiểm tra đầu vào
                if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
                {
                    throw new ArgumentException("Tên đăng nhập và mật khẩu không được để trống");
                }

                // Mã hóa mật khẩu
                string passwordHash = Utils.Helpers.HashPassword(password);

                // Xác thực người dùng
                Account account = _accountRepository.AuthenticateUser(username, passwordHash);

                if (account != null)
                {
                    // Lưu thông tin người dùng hiện tại
                    _currentAccount = account;

                    // Lưu thời gian đăng nhập
                    Properties.Settings.Default.LastLoginDate = DateTime.Now;
                    Properties.Settings.Default.Save();

                    // Ghi log
                    Db.Logger.LogInfo($"Đăng nhập thành công: {username}");
                }
                else
                {
                    // Ghi log
                    Db.Logger.LogWarning($"Đăng nhập thất bại: {username}");
                }

                return account;
            }
            catch (Exception ex)
            {
                Db.Logger.LogException(ex, $"Lỗi khi đăng nhập: {username}");
                throw;
            }
        }

        // Đăng xuất
        public void Logout()
        {
            try
            {
                // Ghi log
                if (_currentAccount != null)
                {
                    Db.Logger.LogInfo($"Đăng xuất: {_currentAccount.Username}");
                }

                // Xóa thông tin người dùng hiện tại
                _currentAccount = null;
            }
            catch (Exception ex)
            {
                Db.Logger.LogException(ex, "Lỗi khi đăng xuất");
                throw;
            }
        }

        // Lấy danh sách tất cả tài khoản
        public List<Account> GetAllAccounts()
        {
            try
            {
                return _accountRepository.GetAllAccounts();
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
                return _accountRepository.GetAccountByID(accountID);
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
                return _accountRepository.GetAllRoles();
            }
            catch (Exception ex)
            {
                Db.Logger.LogException(ex, "Lỗi khi lấy danh sách vai trò");
                throw;
            }
        }

        // Tạo tài khoản mới
        public int CreateAccount(Account account, string password)
        {
            try
            {
                // Kiểm tra đầu vào
                if (string.IsNullOrEmpty(account.Username) || string.IsNullOrEmpty(password))
                {
                    throw new ArgumentException("Tên đăng nhập và mật khẩu không được để trống");
                }

                // Kiểm tra độ mạnh của mật khẩu
                if (!Utils.Validators.IsStrongPassword(password))
                {
                    throw new ArgumentException("Mật khẩu phải có ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt");
                }

                // Tạo salt và hash mật khẩu
                string passwordSalt = Guid.NewGuid().ToString("N");
                string passwordHash = Utils.Helpers.HashPassword(password + passwordSalt);

                // Lấy ID người dùng hiện tại
                int createdBy = _currentAccount != null ? _currentAccount.AccountID : 1; // Mặc định là admin

                // Tạo tài khoản mới
                return _accountRepository.CreateAccount(account, passwordHash, passwordSalt, createdBy);
            }
            catch (Exception ex)
            {
                Db.Logger.LogException(ex, $"Lỗi khi tạo tài khoản: {account.Username}");
                throw;
            }
        }

        // Cập nhật thông tin tài khoản
        public bool UpdateAccount(Account account)
        {
            try
            {
                // Kiểm tra người dùng hiện tại
                if (_currentAccount == null)
                {
                    throw new InvalidOperationException("Bạn cần đăng nhập để thực hiện chức năng này");
                }

                // Kiểm tra quyền
                if (_currentAccount.RoleName != Utils.Constants.ROLE_ADMIN && _currentAccount.AccountID != account.AccountID)
                {
                    throw new UnauthorizedAccessException("Bạn không có quyền cập nhật thông tin tài khoản khác");
                }

                // Cập nhật thông tin tài khoản
                return _accountRepository.UpdateAccount(account, _currentAccount.AccountID);
            }
            catch (Exception ex)
            {
                Db.Logger.LogException(ex, $"Lỗi khi cập nhật tài khoản: {account.AccountID}");
                throw;
            }
        }

        // Đổi mật khẩu
        public bool ChangePassword(int accountID, string oldPassword, string newPassword)
        {
            try
            {
                // Kiểm tra người dùng hiện tại
                if (_currentAccount == null)
                {
                    throw new InvalidOperationException("Bạn cần đăng nhập để thực hiện chức năng này");
                }

                // Kiểm tra quyền
                if (_currentAccount.RoleName != Utils.Constants.ROLE_ADMIN && _currentAccount.AccountID != accountID)
                {
                    throw new UnauthorizedAccessException("Bạn không có quyền đổi mật khẩu tài khoản khác");
                }

                // Kiểm tra độ mạnh của mật khẩu mới
                if (!Utils.Validators.IsStrongPassword(newPassword))
                {
                    throw new ArgumentException("Mật khẩu mới phải có ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt");
                }

                // Lấy thông tin tài khoản
                Account account = _accountRepository.GetAccountByID(accountID);
                if (account == null)
                {
                    throw new ArgumentException("Tài khoản không tồn tại");
                }

                // Tạo hash mật khẩu cũ
                string oldPasswordHash = Utils.Helpers.HashPassword(oldPassword);

                // Tạo salt và hash mật khẩu mới
                string newPasswordSalt = Guid.NewGuid().ToString("N");
                string newPasswordHash = Utils.Helpers.HashPassword(newPassword + newPasswordSalt);

                // Đổi mật khẩu
                return _accountRepository.ChangePassword(accountID, oldPasswordHash, newPasswordHash, newPasswordSalt);
            }
            catch (Exception ex)
            {
                Db.Logger.LogException(ex, $"Lỗi khi đổi mật khẩu: {accountID}");
                throw;
            }
        }

        // Kiểm tra quyền
        public bool HasPermission(string requiredRole)
        {
            // Kiểm tra người dùng hiện tại
            if (_currentAccount == null)
            {
                return false;
            }

            return _currentAccount.HasPermission(requiredRole);
        }
    }
}