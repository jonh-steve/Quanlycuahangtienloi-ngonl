using System;

namespace QuanLyCuaHangTienLoi.Models.DTO
{
    public class AccountDTO
    {
        public int AccountID { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public int RoleID { get; set; }
        public string RoleName { get; set; }
        public DateTime? LastLogin { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public bool IsActive { get; set; }

        // Thuộc tính bổ sung cho hiển thị
        public string LastLoginString => LastLogin.HasValue ? LastLogin.Value.ToString("dd/MM/yyyy HH:mm:ss") : "Chưa đăng nhập";
        public string CreatedDateString => CreatedDate.ToString("dd/MM/yyyy HH:mm:ss");
        public string ModifiedDateString => ModifiedDate.HasValue ? ModifiedDate.Value.ToString("dd/MM/yyyy HH:mm:ss") : "";
        public string StatusString => IsActive ? "Đang hoạt động" : "Bị khóa";

        // Constructor mặc định
        public AccountDTO()
        {
            CreatedDate = DateTime.Now;
            IsActive = true;
        }

        // Constructor từ Entity
        public AccountDTO(Models.Entities.Account account)
        {
            if (account == null)
                return;

            AccountID = account.AccountID;
            Username = account.Username;
            Email = account.Email;
            RoleID = account.RoleID;
            RoleName = account.RoleName;
            LastLogin = account.LastLogin;
            CreatedDate = account.CreatedDate;
            ModifiedDate = account.ModifiedDate;
            IsActive = account.IsActive;
        }

        // Chuyển đổi về Entity
        public Models.Entities.Account ToEntity()
        {
            return new Models.Entities.Account
            {
                AccountID = this.AccountID,
                Username = this.Username,
                Email = this.Email,
                RoleID = this.RoleID,
                RoleName = this.RoleName,
                LastLogin = this.LastLogin,
                CreatedDate = this.CreatedDate,
                ModifiedDate = this.ModifiedDate,
                IsActive = this.IsActive
            };
        }

        public override string ToString()
        {
            return $"{Username} ({RoleName})";
        }
    }
}