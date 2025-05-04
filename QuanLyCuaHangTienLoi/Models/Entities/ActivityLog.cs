using System;

namespace QuanLyCuaHangTienLoi.Models.Entities
{
    public class ActivityLog
    {
        public int ActivityID { get; set; }
        public int AccountID { get; set; }
        public string ActivityType { get; set; } // Create, Update, Delete, Login, Logout, etc.
        public string EntityType { get; set; } // Product, Category, Order, etc.
        public int? EntityID { get; set; }
        public string Description { get; set; }
        public string IPAddress { get; set; }
        public DateTime ActivityDate { get; set; }
        
        // Navigation properties
        public virtual Account Account { get; set; }
        
        public ActivityLog()
        {
            ActivityDate = DateTime.Now;
        }
    }
}