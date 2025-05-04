using System;

namespace QuanLyCuaHangTienLoi.Models.Entities
{
    public class Backup
    {
        public int BackupID { get; set; }
        public string BackupName { get; set; }
        public string BackupPath { get; set; }
        public long BackupSize { get; set; }
        public string BackupType { get; set; } // Full, Differential, Transaction Log
        public string Status { get; set; } // Success, Failed
        public int CreatedBy { get; set; }
        public DateTime CreatedDate { get; set; }
        public string Note { get; set; }
        
        public Backup()
        {
            CreatedDate = DateTime.Now;
        }
    }
}