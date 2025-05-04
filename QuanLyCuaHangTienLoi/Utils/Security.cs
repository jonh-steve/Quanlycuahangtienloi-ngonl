using System;
using System.IO;
using System.Text;
using System.Security.Cryptography;

namespace QuanLyCuaHangTienLoi.Utils
{
    public static class Security
    {
        // Key và IV mặc định cho mã hóa AES
        private static byte[] _key = Encoding.UTF8.GetBytes("QuanLyCuaHangTL!"); // 16 bytes = 128 bits
        private static byte[] _iv = Encoding.UTF8.GetBytes("TienLoiSecure@123"); // 16 bytes = 128 bits

        // Mã hóa chuỗi sử dụng AES
        public static string Encrypt(string plainText)
        {
            if (string.IsNullOrEmpty(plainText))
                return plainText;

            try
            {
                byte[] encrypted;

                using (Aes aesAlg = Aes.Create())
                {
                    aesAlg.Key = _key;
                    aesAlg.IV = _iv;

                    ICryptoTransform encryptor = aesAlg.CreateEncryptor(aesAlg.Key, aesAlg.IV);

                    using (MemoryStream msEncrypt = new MemoryStream())
                    {
                        using (CryptoStream csEncrypt = new CryptoStream(msEncrypt, encryptor, CryptoStreamMode.Write))
                        {
                            using (StreamWriter swEncrypt = new StreamWriter(csEncrypt))
                            {
                                swEncrypt.Write(plainText);
                            }
                            encrypted = msEncrypt.ToArray();
                        }
                    }
                }

                return Convert.ToBase64String(encrypted);
            }
            catch (Exception ex)
            {
                Db.Logger.LogException(ex, "Lỗi khi mã hóa chuỗi");
                throw;
            }
        }

        // Giải mã chuỗi sử dụng AES
        public static string Decrypt(string cipherText)
        {
            if (string.IsNullOrEmpty(cipherText))
                return cipherText;

            try
            {
                byte[] cipherBytes = Convert.FromBase64String(cipherText);
                string plaintext = null;

                using (Aes aesAlg = Aes.Create())
                {
                    aesAlg.Key = _key;
                    aesAlg.IV = _iv;

                    ICryptoTransform decryptor = aesAlg.CreateDecryptor(aesAlg.Key, aesAlg.IV);

                    using (MemoryStream msDecrypt = new MemoryStream(cipherBytes))
                    {
                        using (CryptoStream csDecrypt = new CryptoStream(msDecrypt, decryptor, CryptoStreamMode.Read))
                        {
                            using (StreamReader srDecrypt = new StreamReader(csDecrypt))
                            {
                                plaintext = srDecrypt.ReadToEnd();
                            }
                        }
                    }
                }

                return plaintext;
            }
            catch (Exception ex)
            {
                Db.Logger.LogException(ex, "Lỗi khi giải mã chuỗi");
                throw;
            }
        }

        // Tạo chuỗi ngẫu nhiên bao gồm chữ và số
        public static string GenerateRandomString(int length)
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            var random = new Random();
            var result = new StringBuilder(length);

            for (int i = 0; i < length; i++)
            {
                result.Append(chars[random.Next(chars.Length)]);
            }

            return result.ToString();
        }

        // Tạo salt ngẫu nhiên
        public static string GenerateSalt()
        {
            byte[] salt = new byte[16];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(salt);
            }

            return Convert.ToBase64String(salt);
        }

        // Tạo token xác thực
        public static string GenerateAuthToken(int accountID, string username, DateTime expiry)
        {
            string tokenData = $"{accountID}|{username}|{expiry.ToString("yyyy-MM-dd HH:mm:ss")}";
            return Encrypt(tokenData);
        }

        // Kiểm tra token xác thực có hợp lệ
        public static bool ValidateAuthToken(string token, out int accountID, out string username)
        {
            accountID = 0;
            username = string.Empty;

            if (string.IsNullOrEmpty(token))
                return false;

            try
            {
                string decryptedToken = Decrypt(token);
                string[] parts = decryptedToken.Split('|');

                if (parts.Length != 3)
                    return false;

                accountID = int.Parse(parts[0]);
                username = parts[1];
                DateTime expiry = DateTime.Parse(parts[2]);

                // Kiểm tra token đã hết hạn chưa
                if (expiry < DateTime.Now)
                    return false;

                return true;
            }
            catch
            {
                return false;
            }
        }

        // Đảm bảo mật khẩu đủ mạnh
        public static bool IsStrongPassword(string password)
        {
            // Mật khẩu phải có ít nhất 8 ký tự
            if (string.IsNullOrEmpty(password) || password.Length < 8)
                return false;

            bool hasUpperCase = false;
            bool hasLowerCase = false;
            bool hasDigit = false;
            bool hasSpecialChar = false;

            foreach (char c in password)
            {
                if (char.IsUpper(c))
                    hasUpperCase = true;
                else if (char.IsLower(c))
                    hasLowerCase = true;
                else if (char.IsDigit(c))
                    hasDigit = true;
                else if (!char.IsLetterOrDigit(c))
                    hasSpecialChar = true;
            }

            // Mật khẩu phải có ít nhất 1 chữ hoa, 1 chữ thường, 1 số và 1 ký tự đặc biệt
            return hasUpperCase && hasLowerCase && hasDigit && hasSpecialChar;
        }

        // Băm chuỗi sử dụng SHA256
        public static string HashSHA256(string input)
        {
            if (string.IsNullOrEmpty(input))
                return string.Empty;

            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = Encoding.UTF8.GetBytes(input);
                byte[] hash = sha256.ComputeHash(bytes);

                StringBuilder builder = new StringBuilder();
                for (int i = 0; i < hash.Length; i++)
                {
                    builder.Append(hash[i].ToString("x2"));
                }

                return builder.ToString();
            }
        }

        // Tạo chữ ký số cho dữ liệu
        public static string SignData(string data, string secretKey)
        {
            // Tạo chữ ký HMAC
            using (HMACSHA256 hmac = new HMACSHA256(Encoding.UTF8.GetBytes(secretKey)))
            {
                byte[] dataBytes = Encoding.UTF8.GetBytes(data);
                byte[] signatureBytes = hmac.ComputeHash(dataBytes);

                return Convert.ToBase64String(signatureBytes);
            }
        }

        // Xác thực chữ ký số
        public static bool VerifySignature(string data, string signature, string secretKey)
        {
            // Tạo chữ ký mới từ dữ liệu
            string expectedSignature = SignData(data, secretKey);

            // So sánh chữ ký
            return expectedSignature == signature;
        }
    }
}