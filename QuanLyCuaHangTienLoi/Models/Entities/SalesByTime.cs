using System;

namespace QuanLyCuaHangTienLoi.Models.Entities
{
    public class SalesByTime
    {
        public int SalesByTimeID { get; set; }
        public DateTime SalesDate { get; set; }
        public int HourOfDay { get; set; }
        public int TotalOrders { get; set; }
        public int TotalItems { get; set; }
        public decimal TotalSales { get; set; }
        public DateTime CreatedDate { get; set; }
        
        public SalesByTime()
        {
            CreatedDate = DateTime.Now;
            SalesDate = DateTime.Today;
        }
    }
}