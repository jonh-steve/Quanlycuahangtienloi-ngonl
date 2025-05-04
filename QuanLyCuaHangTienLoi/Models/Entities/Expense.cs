using System;

namespace QuanLyCuaHangTienLoi.Models.Entities
{
    public class Expense
    {
        public int ExpenseID { get; set; }
        public string ExpenseCode { get; set; }
        public string ExpenseType { get; set; } // Rent, Utilities, Salary, etc.
        public string Description { get; set; }
        public decimal Amount { get; set; }
        public DateTime ExpenseDate { get; set; }
        public string PaymentMethod { get; set; }
        public string ReferenceNumber { get; set; }
        public string Recipient { get; set; }
        public string Status { get; set; } // Pending, Paid, Cancelled
        public string Note { get; set; }
        public int CreatedBy { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public int? ModifiedBy { get; set; }
        
        public Expense()
        {
            CreatedDate = DateTime.Now;
            ExpenseDate = DateTime.Today;
            Status = "Pending";
        }
    }
}