using System;

namespace QuanLyCuaHangTienLoi.Models.Entities
{
    public class CategorySales
    {
        public int CategorySalesID { get; set; }
        public int CategoryID { get; set; }
        public DateTime SalesDate { get; set; }
        public int QuantitySold { get; set; }
        public decimal TotalSales { get; set; }
        public decimal TotalCost { get; set; }
        public decimal GrossProfit { get; set; }
        public DateTime CreatedDate { get; set; }
        
        // Navigation properties
        public virtual Category Category { get; set; }
        
        public CategorySales()
        {
            CreatedDate = DateTime.Now;
            SalesDate = DateTime.Today;
        }
    }
}