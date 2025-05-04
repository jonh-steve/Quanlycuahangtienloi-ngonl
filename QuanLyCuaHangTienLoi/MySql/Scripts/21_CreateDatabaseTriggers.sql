USE QuanLyCuaHangTienLoi;
GO

-- Trigger to update product price history when product price changes
CREATE TRIGGER app.trg_Product_PriceHistory
ON app.Product
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if cost price or sell price has changed
    IF UPDATE(CostPrice) OR UPDATE(SellPrice)
    BEGIN
        -- Get the updated products with price changes
        INSERT INTO app.ProductPrice (
            ProductID, CostPrice, SellPrice, EffectiveDate
        )
        SELECT 
            i.ProductID, 
            i.CostPrice, 
            i.SellPrice, 
            GETDATE()
        FROM 
            inserted i
        INNER JOIN 
            deleted d ON i.ProductID = d.ProductID
        WHERE 
            i.CostPrice <> d.CostPrice OR i.SellPrice <> d.SellPrice;
        
        -- End the previous price periods
        UPDATE pp
        SET EndDate = GETDATE()
        FROM app.ProductPrice pp
        INNER JOIN inserted i ON pp.ProductID = i.ProductID
        INNER JOIN deleted d ON i.ProductID = d.ProductID
        WHERE 
            pp.EndDate IS NULL
            AND (i.CostPrice <> d.CostPrice OR i.SellPrice <> d.SellPrice)
            AND pp.EffectiveDate < GETDATE();
    END
END
GO

-- Trigger to update inventory when order is placed
CREATE TRIGGER app.trg_OrderDetail_UpdateInventory
ON app.OrderDetail
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Update inventory for each product in the order
    UPDATE i
    SET 
        i.Quantity = i.Quantity - od.Quantity,
        i.LastUpdated = GETDATE()
    FROM 
        app.Inventory i
    INNER JOIN 
        inserted od ON i.ProductID = od.ProductID;
    
    -- Record inventory transactions
    INSERT INTO app.InventoryTransaction (
        ProductID, TransactionType, Quantity, PreviousQuantity, 
        CurrentQuantity, UnitPrice, TotalAmount, 
        ReferenceID, ReferenceType, TransactionDate
    )
    SELECT 
        od.ProductID, 
        'Sale', 
        od.Quantity, 
        i.Quantity + od.Quantity, 
        i.Quantity, 
        od.UnitPrice, 
        od.TotalPrice, 
        od.OrderID, 
        'Order', 
        GETDATE()
    FROM 
        inserted od
    INNER JOIN 
        app.Inventory i ON od.ProductID = i.ProductID;
END
GO

-- Trigger to update inventory when order is cancelled
CREATE TRIGGER app.trg_Order_CancelUpdateInventory
ON app.Order
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if order status changed to Cancelled
    IF EXISTS (
        SELECT 1 
        FROM inserted i 
        INNER JOIN deleted d ON i.OrderID = d.OrderID
        WHERE i.PaymentStatus = 'Cancelled' AND d.PaymentStatus <> 'Cancelled'
    )
    BEGIN
        -- Get the cancelled orders
        DECLARE @CancelledOrders TABLE (OrderID INT);
        
        INSERT INTO @CancelledOrders
        SELECT i.OrderID
        FROM inserted i
        INNER JOIN deleted d ON i.OrderID = d.OrderID
        WHERE i.PaymentStatus = 'Cancelled' AND d.PaymentStatus <> 'Cancelled';
        
        -- Update inventory for each product in the cancelled orders
        UPDATE i
        SET 
            i.Quantity = i.Quantity + od.Quantity,
            i.LastUpdated = GETDATE()
        FROM 
            app.Inventory i
        INNER JOIN 
            app.OrderDetail od ON i.ProductID = od.ProductID
        INNER JOIN 
            @CancelledOrders co ON od.OrderID = co.OrderID;
        
        -- Record inventory transactions
        INSERT INTO app.InventoryTransaction (
            ProductID, TransactionType, Quantity, PreviousQuantity, 
            CurrentQuantity, UnitPrice, TotalAmount, 
            ReferenceID, ReferenceType, Note, TransactionDate
        )
        SELECT 
            od.ProductID, 
            'Return', 
            od.Quantity, 
            i.Quantity - od.Quantity, 
            i.Quantity, 
            od.UnitPrice, 
            od.TotalPrice, 
            od.OrderID, 
            'OrderCancel', 
            'Order cancelled', 
            GETDATE()
        FROM 
            app.OrderDetail od
        INNER JOIN 
            @CancelledOrders co ON od.OrderID = co.OrderID
        INNER JOIN 
            app.Inventory i ON od.ProductID = i.ProductID;
    END
END
GO

-- Trigger to update inventory when import detail is inserted
CREATE TRIGGER app.trg_ImportDetail_UpdateInventory
ON app.ImportDetail
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Update inventory for each product in the import
    MERGE app.Inventory AS target
    USING (
        SELECT 
            id.ProductID, 
            id.Quantity
        FROM 
            inserted id
    ) AS source
    ON target.ProductID = source.ProductID
    WHEN MATCHED THEN
        UPDATE SET 
            Quantity = target.Quantity + source.Quantity,
            LastUpdated = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (ProductID, Quantity, LastUpdated)
        VALUES (source.ProductID, source.Quantity, GETDATE());
    
    -- Record inventory transactions
    INSERT INTO app.InventoryTransaction (
        ProductID, TransactionType, Quantity, PreviousQuantity, 
        CurrentQuantity, UnitPrice, TotalAmount, 
        ReferenceID, ReferenceType, TransactionDate
    )
    SELECT 
        id.ProductID, 
        'Import', 
        id.Quantity, 
        ISNULL(i.Quantity - id.Quantity, 0), 
        ISNULL(i.Quantity, id.Quantity), 
        id.UnitPrice, 
        id.TotalPrice, 
        id.ImportID, 
        'Import', 
        GETDATE()
    FROM 
        inserted id
    LEFT JOIN 
        app.Inventory i ON id.ProductID = i.ProductID;
END
GO

-- Trigger to update order totals when order details change
CREATE TRIGGER app.trg_OrderDetail_UpdateOrderTotals
ON app.OrderDetail
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get the affected order IDs
    DECLARE @AffectedOrders TABLE (OrderID INT);
    
    INSERT INTO @AffectedOrders
    SELECT OrderID FROM inserted
    UNION
    SELECT OrderID FROM deleted;
    
    -- Update order totals
    UPDATE o
    SET 
        o.TotalAmount = ISNULL(subquery.TotalAmount, 0),
        o.FinalAmount = ISNULL(subquery.TotalAmount, 0) + o.Tax - o.Discount,
        o.ModifiedDate = GETDATE()
    FROM 
        app.Order o
    INNER JOIN (
        SELECT 
            OrderID, 
            SUM(TotalPrice) AS TotalAmount
        FROM 
            app.OrderDetail
        WHERE 
            OrderID IN (SELECT OrderID FROM @AffectedOrders)
        GROUP BY 
            OrderID
    ) AS subquery ON o.OrderID = subquery.OrderID;
END
GO

-- Trigger to update import totals when import details change
CREATE TRIGGER app.trg_ImportDetail_UpdateImportTotals
ON app.ImportDetail
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get the affected import IDs
    DECLARE @AffectedImports TABLE (ImportID INT);
    
    INSERT INTO @AffectedImports
    SELECT ImportID FROM inserted
    UNION
    SELECT ImportID FROM deleted;
    
    -- Update import totals
    UPDATE i
    SET 
        i.TotalAmount = ISNULL(subquery.TotalAmount, 0),
        i.ModifiedDate = GETDATE()
    FROM 
        app.Import i
    INNER JOIN (
        SELECT 
            ImportID, 
            SUM(TotalPrice) AS TotalAmount
        FROM 
            app.ImportDetail
        WHERE 
            ImportID IN (SELECT ImportID FROM @AffectedImports)
        GROUP BY 
            ImportID
    ) AS subquery ON i.ImportID = subquery.ImportID;
END
GO

-- Trigger to update daily sales when order is placed or cancelled
CREATE TRIGGER app.trg_Order_UpdateDailySales
ON app.Order
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get the affected dates
    DECLARE @AffectedDates TABLE (SalesDate DATE);
    
    INSERT INTO @AffectedDates
    SELECT DISTINCT CAST(OrderDate AS DATE) FROM inserted
    UNION
    SELECT DISTINCT CAST(OrderDate AS DATE) FROM deleted
    WHERE PaymentStatus <> 'Cancelled';
    
    -- For each affected date, recalculate daily sales
    DECLARE @SalesDate DATE;
    DECLARE date_cursor CURSOR FOR
    SELECT SalesDate FROM @AffectedDates;
    
    OPEN date_cursor;
    FETCH NEXT FROM date_cursor INTO @SalesDate;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Calculate sales totals for the date
        DECLARE @OrderCount INT, @TotalSales DECIMAL(18, 2), @TotalCost DECIMAL(18, 2);
        
        SELECT 
            @OrderCount = COUNT(DISTINCT o.OrderID),
            @TotalSales = SUM(o.FinalAmount)
        FROM 
            app.Order o
        WHERE 
            CAST(o.OrderDate AS DATE) = @SalesDate
            AND o.PaymentStatus = 'Paid';
        
        SELECT 
            @TotalCost = SUM(od.Quantity * p.CostPrice)
        FROM 
            app.OrderDetail od
        INNER JOIN 
            app.Order o ON od.OrderID = o.OrderID
        INNER JOIN 
            app.Product p ON od.ProductID = p.ProductID
        WHERE 
            CAST(o.OrderDate AS DATE) = @SalesDate
            AND o.PaymentStatus = 'Paid';
        
        -- If no sales for the date, set defaults
        SET @OrderCount = ISNULL(@OrderCount, 0);
        SET @TotalSales = ISNULL(@TotalSales, 0);
        SET @TotalCost = ISNULL(@TotalCost, 0);
        
        -- Update or insert daily sales record
        MERGE app.DailySales AS target
        USING (SELECT @SalesDate AS SalesDate) AS source
        ON target.SalesDate = source.SalesDate
        WHEN MATCHED THEN
            UPDATE SET 
                TotalOrders = @OrderCount,
                TotalSales = @TotalSales,
                TotalCost = @TotalCost,
                GrossProfit = @TotalSales - @TotalCost,
                UpdatedDate = GETDATE()
        WHEN NOT MATCHED THEN
            INSERT (SalesDate, TotalOrders, TotalSales, TotalCost, GrossProfit, CreatedDate)
            VALUES (@SalesDate, @OrderCount, @TotalSales, @TotalCost, @TotalSales - @TotalCost, GETDATE());
        
        FETCH NEXT FROM date_cursor INTO @SalesDate;
    END
    
    CLOSE date_cursor;
    DEALLOCATE date_cursor;
END
GO

-- Trigger to update product sales when order is placed or cancelled
CREATE TRIGGER app.trg_OrderDetail_UpdateProductSales
ON app.OrderDetail
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get the affected order IDs
    DECLARE @AffectedOrders TABLE (OrderID INT);
    
    INSERT INTO @AffectedOrders
    SELECT OrderID FROM inserted
    UNION
    SELECT OrderID FROM deleted;
    
    -- Get the affected products and dates
    DECLARE @AffectedProductDates TABLE (
        ProductID INT,
        SalesDate DATE
    );
    
    INSERT INTO @AffectedProductDates
    SELECT 
        od.ProductID,
        CAST(o.OrderDate AS DATE) AS SalesDate
    FROM 
        app.OrderDetail od
    INNER JOIN 
        app.Order o ON od.OrderID = o.OrderID
    WHERE 
        o.OrderID IN (SELECT OrderID FROM @AffectedOrders);
    
    -- For each affected product and date, recalculate product sales
    MERGE app.ProductSales AS target
    USING (
        SELECT 
            pd.ProductID,
            pd.SalesDate,
            COUNT(DISTINCT o.OrderID) AS OrderCount,
            SUM(od.Quantity) AS QuantitySold,
            SUM(od.TotalPrice) AS TotalSales,
            SUM(od.Quantity * p.CostPrice) AS TotalCost,
            SUM(od.TotalPrice) - SUM(od.Quantity * p.CostPrice) AS Profit
        FROM 
            @AffectedProductDates pd
        INNER JOIN 
            app.Order o ON CAST(o.OrderDate AS DATE) = pd.SalesDate
        INNER JOIN 
            app.OrderDetail od ON o.OrderID = od.OrderID AND od.ProductID = pd.ProductID
        INNER JOIN 
            app.Product p ON od.ProductID = p.ProductID
        WHERE 
            o.PaymentStatus = 'Paid'
        GROUP BY 
            pd.ProductID, pd.SalesDate
    ) AS source
    ON target.ProductID = source.ProductID AND target.SalesDate = source.SalesDate
    WHEN MATCHED THEN
        UPDATE SET 
            QuantitySold = source.QuantitySold,
            TotalSales = source.TotalSales,
            TotalCost = source.TotalCost,
            Profit = source.Profit,
            UpdatedDate = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (ProductID, SalesDate, QuantitySold, TotalSales, TotalCost, Profit, CreatedDate)
        VALUES (source.ProductID, source.SalesDate, source.QuantitySold, source.TotalSales, source.TotalCost, source.Profit, GETDATE());
END
GO

PRINT 'Database triggers created successfully';