using System;

namespace QuanLyCuaHangTienLoi.Models.Entities
{
    public class SystemConfig
    {
        public int ConfigID { get; set; }
        public string ConfigKey { get; set; }
        public string ConfigValue { get; set; }
        public string ConfigGroup { get; set; }
        public string Description { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public int? ModifiedBy { get; set; }
        
        public SystemConfig()
        {
            CreatedDate = DateTime.Now;
            IsActive = true;
        }
    }
}