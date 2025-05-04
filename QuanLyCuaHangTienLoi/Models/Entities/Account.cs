using System;

namespace QuanLyCuaHangTienLoi.Models.Entities
{
    public class Account
    {
        public int AccountID { get; set; }
        public string Username { get; set; }
        public string PasswordHash { get; set; }
        public string PasswordSalt { get; set; }
        public string Email { get; set; }
        public int RoleID { get; set; }
        public DateTime? LastLogin { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public bool IsActive { get; set; }

        // Thuộc tính bổ sung (không map trực tiếp từ DB)
        public string RoleName { get; set; }

        public Account()
        {
            // Constructor mặc định
            CreatedDate = DateTime.Now;
            IsActive = true;
        }

        // Kiểm tra quyền
        public bool HasPermission(string requiredRole)
        {
            // Giai đoạn 1: Triển khai đơn giản
            if (string.IsNullOrEmpty(RoleName))
            {
                return false;
            }

            // Admin có tất cả quyền
            if (RoleName == Utils.Constants.ROLE_ADMIN)
            {
                return true;
            }

            // Kiểm tra quyền theo vai trò
            switch (requiredRole)
            {
                case Utils.Constants.ROLE_MANAGER:
                    return RoleName == Utils.Constants.ROLE_MANAGER;

                case Utils.Constants.ROLE_CASHIER:
                    return RoleName == Utils.Constants.ROLE_MANAGER ||
                           RoleName == Utils.Constants.ROLE_CASHIER;

                case Utils.Constants.ROLE_INVENTORY:
                    return RoleName == Utils.Constants.ROLE_MANAGER ||
                           RoleName == Utils.Constants.ROLE_INVENTORY;

                default:
                    return false;
            }
        }

        // Thời gian đã đăng nhập
        public TimeSpan? LoginDuration()
        {
            if (!LastLogin.HasValue)
            {
                return null;
            }

            return DateTime.Now - LastLogin.Value;
        }

        // Kiểm tra tài khoản có đang hoạt động
        public bool IsActiveAccount()
        {
            return IsActive;
        }

        public override string ToString()
        {
            return $"{Username} ({RoleName})";
        }
    }
}