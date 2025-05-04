using Microsoft.EntityFrameworkCore;
using QuanLyCuaHangTienLoi.Models.Entities;
using System;

namespace QuanLyCuaHangTienLoi.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        // Quản lý tài khoản và nhân viên
        public DbSet<Role> Roles { get; set; }
        public DbSet<Account> Accounts { get; set; }
        public DbSet<Employee> Employees { get; set; }
        public DbSet<EmployeeSchedule> EmployeeSchedules { get; set; }
        public DbSet<EmployeeAttendance> EmployeeAttendances { get; set; }

        // Quản lý sản phẩm
        public DbSet<Category> Categories { get; set; }
        public DbSet<Product> Products { get; set; }
        public DbSet<ProductPrice> ProductPrices { get; set; }
        public DbSet<ProductImage> ProductImages { get; set; }

        // Quản lý kho hàng
        public DbSet<Inventory> Inventories { get; set; }
        public DbSet<InventoryTransaction> InventoryTransactions { get; set; }
        public DbSet<Import> Imports { get; set; }
        public DbSet<ImportDetail> ImportDetails { get; set; }

        // Quản lý đơn hàng
        public DbSet<Customer> Customers { get; set; }
        public DbSet<Order> Orders { get; set; }
        public DbSet<OrderDetail> OrderDetails { get; set; }
        public DbSet<PaymentMethod> PaymentMethods { get; set; }

        // Quản lý nhà cung cấp
        public DbSet<Supplier> Suppliers { get; set; }

        // Báo cáo và thống kê
        public DbSet<DailySales> DailySales { get; set; }
        public DbSet<ProductSales> ProductSales { get; set; }
        public DbSet<CategorySales> CategorySales { get; set; }
        public DbSet<SalesByTime> SalesByTime { get; set; }
        public DbSet<Expense> Expenses { get; set; }

        // Cấu hình hệ thống
        public DbSet<SystemConfig> SystemConfigs { get; set; }
        public DbSet<SystemLog> SystemLogs { get; set; }
        public DbSet<ActivityLog> ActivityLogs { get; set; }
        public DbSet<Backup> Backups { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Thiết lập schema cho tất cả các entity
            modelBuilder.HasDefaultSchema("app");

            // Cấu hình quan hệ giữa các entity

            // Quản lý tài khoản và nhân viên
            modelBuilder.Entity<Account>()
                .HasOne(a => a.Role)
                .WithMany(r => r.Accounts)
                .HasForeignKey(a => a.RoleID);

            modelBuilder.Entity<Employee>()
                .HasOne(e => e.Account)
                .WithOne(a => a.Employee)
                .HasForeignKey<Employee>(e => e.AccountID);

            modelBuilder.Entity<EmployeeSchedule>()
                .HasOne(es => es.Employee)
                .WithMany(e => e.Schedules)
                .HasForeignKey(es => es.EmployeeID);

            modelBuilder.Entity<EmployeeAttendance>()
                .HasOne(ea => ea.Employee)
                .WithMany(e => e.Attendances)
                .HasForeignKey(ea => ea.EmployeeID);

            // Quản lý sản phẩm
            modelBuilder.Entity<Category>()
                .HasOne(c => c.ParentCategory)
                .WithMany(c => c.ChildCategories)
                .HasForeignKey(c => c.ParentCategoryID)
                .IsRequired(false)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Product>()
                .HasOne(p => p.Category)
                .WithMany(c => c.Products)
                .HasForeignKey(p => p.CategoryID);

            modelBuilder.Entity<ProductPrice>()
                .HasOne(pp => pp.Product)
                .WithMany(p => p.ProductPrices)
                .HasForeignKey(pp => pp.ProductID);

            modelBuilder.Entity<ProductImage>()
                .HasOne(pi => pi.Product)
                .WithMany(p => p.ProductImages)
                .HasForeignKey(pi => pi.ProductID);

            // Quản lý kho hàng
            modelBuilder.Entity<Inventory>()
                .HasOne(i => i.Product)
                .WithMany(p => p.Inventories)
                .HasForeignKey(i => i.ProductID);

            modelBuilder.Entity<InventoryTransaction>()
                .HasOne(it => it.Inventory)
                .WithMany(i => i.Transactions)
                .HasForeignKey(it => it.InventoryID);

            modelBuilder.Entity<Import>()
                .HasOne(i => i.Supplier)
                .WithMany(s => s.Imports)
                .HasForeignKey(i => i.SupplierID);

            modelBuilder.Entity<ImportDetail>()
                .HasOne(id => id.Import)
                .WithMany(i => i.ImportDetails)
                .HasForeignKey(id => id.ImportID);

            modelBuilder.Entity<ImportDetail>()
                .HasOne(id => id.Product)
                .WithMany(p => p.ImportDetails)
                .HasForeignKey(id => id.ProductID);

            // Quản lý đơn hàng
            modelBuilder.Entity<Order>()
                .HasOne(o => o.Customer)
                .WithMany(c => c.Orders)
                .HasForeignKey(o => o.CustomerID)
                .IsRequired(false);

            modelBuilder.Entity<Order>()
                .HasOne(o => o.PaymentMethod)
                .WithMany(pm => pm.Orders)
                .HasForeignKey(o => o.PaymentMethodID);

            modelBuilder.Entity<OrderDetail>()
                .HasOne(od => od.Order)
                .WithMany(o => o.OrderDetails)
                .HasForeignKey(od => od.OrderID);

            modelBuilder.Entity<OrderDetail>()
                .HasOne(od => od.Product)
                .WithMany(p => p.OrderDetails)
                .HasForeignKey(od => od.ProductID);

            // Báo cáo và thống kê
            modelBuilder.Entity<ProductSales>()
                .HasOne(ps => ps.Product)
                .WithMany()
                .HasForeignKey(ps => ps.ProductID);

            modelBuilder.Entity<CategorySales>()
                .HasOne(cs => cs.Category)
                .WithMany()
                .HasForeignKey(cs => cs.CategoryID);

            // Cấu hình hệ thống
            modelBuilder.Entity<ActivityLog>()
                .HasOne(al => al.Account)
                .WithMany(a => a.ActivityLogs)
                .HasForeignKey(al => al.AccountID);
        }
    }
}