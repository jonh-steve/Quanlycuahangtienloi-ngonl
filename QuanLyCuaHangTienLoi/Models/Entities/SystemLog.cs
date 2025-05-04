using System;

namespace QuanLyCuaHangTienLoi.Models.Entities
{
    public class SystemLog
    {
        public int LogID { get; set; }
        public string LogLevel { get; set; } // Info, Warning, Error, Critical
        public string LogSource { get; set; }
        public string Message { get; set; }
        public string StackTrace { get; set; }
        public string UserName { get; set; }
        public string IPAddress { get; set; }
        public DateTime LogDate { get; set; }
        
        public SystemLog()
        {
            LogDate = DateTime.Now;
        }
    }
}