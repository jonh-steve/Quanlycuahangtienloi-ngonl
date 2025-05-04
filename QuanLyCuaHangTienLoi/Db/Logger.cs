using System;
using System.IO;

namespace QuanLyCuaHangTienLoi.Db
{
    public enum LogLevel
    {
        Info,
        Warning,
        Error,
        Debug
    }

    public static class Logger
    {
        private static readonly string _logFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Logs", "AppLog.txt");

        static Logger()
        {
            // Đảm bảo thư mục Logs tồn tại
            string logDirectory = Path.GetDirectoryName(_logFilePath);
            if (!Directory.Exists(logDirectory))
            {
                Directory.CreateDirectory(logDirectory);
            }
        }

        public static void Log(string message, LogLevel level = LogLevel.Info)
        {
            try
            {
                string logMessage = $"{DateTime.Now:yyyy-MM-dd HH:mm:ss} [{level}] - {message}";

                // Ghi log vào file
                using (StreamWriter writer = File.AppendText(_logFilePath))
                {
                    writer.WriteLine(logMessage);
                }

                // Hiển thị log ra console trong môi trường debug
#if DEBUG
                Console.WriteLine(logMessage);
#endif
            }
            catch (Exception ex)
            {
                // Không thể ghi log, hiển thị lỗi ra console
                Console.WriteLine($"Lỗi khi ghi log: {ex.Message}");
            }
        }

        public static void LogInfo(string message)
        {
            Log(message, LogLevel.Info);
        }

        public static void LogWarning(string message)
        {
            Log(message, LogLevel.Warning);
        }

        public static void LogError(string message)
        {
            Log(message, LogLevel.Error);
        }

        public static void LogDebug(string message)
        {
#if DEBUG
            Log(message, LogLevel.Debug);
#endif
        }

        public static void LogException(Exception ex, string additionalInfo = "")
        {
            string message = $"Exception: {ex.Message}";
            if (!string.IsNullOrEmpty(additionalInfo))
            {
                message += $" | Additional Info: {additionalInfo}";
            }
            message += $" | StackTrace: {ex.StackTrace}";

            Log(message, LogLevel.Error);
        }
    }
}