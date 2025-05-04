using System;
using System.Text.RegularExpressions;

namespace QuanLyCuaHangTienLoi.Utils
{
    public static class Validators
    {
        // Kiểm tra chuỗi rỗng hoặc null
        public static bool IsNullOrEmpty(string value)
        {
            return string.IsNullOrEmpty(value?.Trim());
        }

        // Kiểm tra độ dài chuỗi
        public static bool IsValidLength(string value, int minLength, int maxLength)
        {
            if (value == null)
            {
                return false;
            }

            int length = value.Trim().Length;
            return length >= minLength && length <= maxLength;
        }

        // Kiểm tra định dạng email
        public static bool IsValidEmail(string email)
        {
            if (IsNullOrEmpty(email))
            {
                return false;
            }

            // Sử dụng Regex để kiểm tra định dạng email
            string pattern = @"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
            return Regex.IsMatch(email, pattern);
        }

        // Kiểm tra định dạng số điện thoại Việt Nam
        public static bool IsValidVietnamesePhoneNumber(string phoneNumber)
        {
            if (IsNullOrEmpty(phoneNumber))
            {
                return false;
            }

            // Kiểm tra số điện thoại Việt Nam (bắt đầu bằng 0 hoặc +84 và có 10 hoặc 11 số)
            string pattern = @"^(0|\+84)(\d{9,10})$";
            return Regex.IsMatch(phoneNumber, pattern);
        }

        // Kiểm tra định dạng mật khẩu (ít nhất 8 ký tự, có chữ hoa, chữ thường và số)
        public static bool IsStrongPassword(string password)
        {
            if (IsNullOrEmpty(password) || password.Length < 8)
            {
                return false;
            }

            // Kiểm tra có ít nhất 1 chữ hoa, 1 chữ thường, 1 số và 1 ký tự đặc biệt
            bool hasUpperCase = false;
            bool hasLowerCase = false;
            bool hasDigit = false;
            bool hasSpecialChar = false;

            foreach (char c in password)
            {
                if (char.IsUpper(c))
                {
                    hasUpperCase = true;
                }
                else if (char.IsLower(c))
                {
                    hasLowerCase = true;
                }
                else if (char.IsDigit(c))
                {
                    hasDigit = true;
                }
                else if (!char.IsLetterOrDigit(c))
                {
                    hasSpecialChar = true;
                }
            }

            return hasUpperCase && hasLowerCase && hasDigit && hasSpecialChar;
        }

        // Kiểm tra định dạng số
        public static bool IsNumeric(string value)
        {
            if (IsNullOrEmpty(value))
            {
                return false;
            }

            return decimal.TryParse(value, out _);
        }

        // Kiểm tra số dương
        public static bool IsPositiveNumber(string value)
        {
            if (!IsNumeric(value))
            {
                return false;
            }

            return decimal.Parse(value) > 0;
        }

        // Kiểm tra định dạng ngày tháng
        public static bool IsValidDate(string date)
        {
            if (IsNullOrEmpty(date))
            {
                return false;
            }

            return DateTime.TryParse(date, out _);
        }

        // Kiểm tra ngày hợp lệ (không quá khứ)
        public static bool IsValidFutureDate(string date)
        {
            if (!IsValidDate(date))
            {
                return false;
            }

            return DateTime.Parse(date) >= DateTime.Today;
        }

        // Kiểm tra mã barcode hợp lệ
        public static bool IsValidBarcode(string barcode)
        {
            if (IsNullOrEmpty(barcode))
            {
                return false;
            }

            // Kiểm tra barcode EAN-13
            string pattern = @"^\d{13}$";
            return Regex.IsMatch(barcode, pattern);
        }
    }
}