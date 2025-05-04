USE QuanLyCuaHangTienLoi;
GO

-- Stored procedure to create new order
CREATE PROCEDURE app.sp_CreateOrder
    @CustomerID INT = NULL,
    @EmployeeID INT,
    @PaymentMethodID INT,
    @Note NVARCHAR(500) = NULL,
    @OrderItems app.OrderItemType READONLY -- Custom table type for order items
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Generate order code (format: ORD + YYYYMMDD + 4-digit sequence)
        DECLARE @OrderDate DATE = GETDATE();
        DECLARE @DatePart NVARCHAR(8) = FORMAT(@OrderDate, 'yyyyMMdd');
        DECLARE @Sequence INT = 1;
        
        -- Get the last sequence for today
        SELECT @Sequence = ISNULL(MAX(CAST(SUBSTRING(OrderCode, 12, 4) AS INT)), 0) + 1
        FROM app.Order
        WHERE SUBSTRING(OrderCode, 4, 8) = @DatePart;
        
        DECLARE @OrderCode NVARCHAR(20) = 'ORD' + @DatePart + RIGHT('0000' + CAST(@Sequence AS NVARCHAR(4)), 4);
        
        -- Calculate totals
        DECLARE @TotalAmount DECIMAL(18, 2) = 0;
        SELECT @TotalAmount = SUM(Quantity * UnitPrice)
        FROM @OrderItems;
        
        -- Get tax rate from system config
        DECLARE @TaxRate DECIMAL(18, 2) = 0;
        SELECT @TaxRate = CAST(ConfigValue AS DECIMAL(18, 2))
        FROM app.SystemConfig
        WHERE ConfigKey = 'TaxRate';
        
        DECLARE @Tax DECIMAL(18, 2) = @TotalAmount * (@TaxRate / 100);
        DECLARE @FinalAmount DECIMAL(18, 2) = @TotalAmount + @Tax;
        
        -- Create order
        INSERT INTO app.Order (
            OrderCode, CustomerID, EmployeeID, OrderDate, 
            TotalAmount, Tax, FinalAmount, 
            PaymentMethodID, PaymentStatus, Note, CreatedDate
        )
        VALUES (
            @OrderCode, @CustomerID, @EmployeeID, GETDATE(), 
            @TotalAmount, @Tax, @FinalAmount, 
            @PaymentMethodID, 'Paid', @Note, GETDATE()
        );
        
        -- Get the new order ID
        DECLARE @OrderID INT = SCOPE_IDENTITY();
        
        -- Insert order details and update inventory
        INSERT INTO app.OrderDetail (
            OrderID, ProductID, Quantity, UnitPrice, Discount, TotalPrice
        )
        SELECT 
            @OrderID, 
            ProductID, 
            Quantity, 
            UnitPrice, 
            Discount, 
            (Quantity * UnitPrice) - Discount
        FROM 
            @OrderItems;
        
        -- Update inventory for each product
        DECLARE @ProductID INT, @Quantity INT, @UnitPrice DECIMAL(18, 2);
        DECLARE orderItems_cursor CURSOR FOR
        SELECT ProductID, Quantity, UnitPrice FROM @OrderItems;
        
        OPEN orderItems_cursor;
        FETCH NEXT FROM orderItems_cursor INTO @ProductID, @Quantity, @UnitPrice;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Get current inventory
            DECLARE @CurrentStock INT;
            SELECT @CurrentStock = Quantity FROM app.Inventory WHERE ProductID = @ProductID;
            
            -- Update inventory
            UPDATE app.Inventory
            SET Quantity = Quantity - @Quantity, LastUpdated = GETDATE()
            WHERE ProductID = @ProductID;
            
            -- Record inventory transaction
            INSERT INTO app.InventoryTransaction (
                ProductID, TransactionType, Quantity, PreviousQuantity, 
                CurrentQuantity, UnitPrice, TotalAmount, 
                ReferenceID, ReferenceType, TransactionDate
            )
            VALUES (
                @ProductID, 'Sale', @Quantity, @CurrentStock, 
                @CurrentStock - @Quantity, @UnitPrice, @UnitPrice * @Quantity, 
                @OrderID, 'Order', GETDATE()
            );
            
            FETCH NEXT FROM orderItems_cursor INTO @ProductID, @Quantity, @UnitPrice;
        END
        
        CLOSE orderItems_cursor;
        DEALLOCATE orderItems_cursor;
        
        -- Log the activity
        INSERT INTO app.ActivityLog (
            AccountID, ActivityType, EntityType, EntityID, Description
        )
        VALUES (
            @EmployeeID, 'Create', 'Order', @OrderID, 
            'Created new order: ' + @OrderCode
        );
        
        COMMIT;
        
        -- Return the new order info
        SELECT 
            @OrderID AS OrderID, 
            @OrderCode AS OrderCode, 
            @FinalAmount AS FinalAmount;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END
GO

-- Create custom table type for order items
CREATE TYPE app.OrderItemType AS TABLE (
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(18, 2),
    Discount DECIMAL(18, 2)
);
GO

-- Stored procedure to get order by ID
CREATE PROCEDURE app.sp_GetOrderByID
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get order header
    SELECT 
        o.OrderID,
        o.OrderCode,
        o.OrderDate,
        o.TotalAmount,
        o.Discount,
        o.Tax,
        o.FinalAmount,
        o.PaymentStatus,
        o.Note,
        pm.MethodName AS PaymentMethod,
        c.CustomerID,
        c.CustomerName,
        c.PhoneNumber AS CustomerPhone,
        e.EmployeeID,
        e.FullName AS EmployeeName
    FROM 
        app.Order o
    LEFT JOIN 
        app.Customer c ON o.CustomerID = c.CustomerID
    INNER JOIN 
        app.Employee e ON o.EmployeeID = e.EmployeeID
    INNER JOIN 
        app.PaymentMethod pm ON o.PaymentMethodID = pm.PaymentMethodID
    WHERE 
        o.OrderID = @OrderID;
    
    -- Get order details
    SELECT 
        od.OrderDetailID,
        od.ProductID,
        p.ProductName,
        p.ProductCode,
        od.Quantity,
        od.UnitPrice,
        od.Discount,
        od.TotalPrice,
        p.Unit
    FROM 
        app.OrderDetail od
    INNER JOIN 
        app.Product p ON od.ProductID = p.ProductID
    WHERE 
        od.OrderID = @OrderID;
END
GO

-- Stored procedure to get orders by date range
CREATE PROCEDURE app.sp_GetOrdersByDateRange
    @StartDate DATE,
    @EndDate DATE,
    @EmployeeID INT = NULL,
    @PaymentStatus NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        o.OrderID,
        o.OrderCode,
        o.OrderDate,
        o.TotalAmount,
        o.Tax,
        o.FinalAmount,
        o.PaymentStatus,
        pm.MethodName AS PaymentMethod,
        c.CustomerName,
        e.FullName AS EmployeeName,
        (SELECT COUNT(*) FROM app.OrderDetail WHERE OrderID = o.OrderID) AS ItemCount
    FROM 
        app.Order o
    LEFT JOIN 
        app.Customer c ON o.CustomerID = c.CustomerID
    INNER JOIN 
        app.Employee e ON o.EmployeeID = e.EmployeeID
    INNER JOIN 
        app.PaymentMethod pm ON o.PaymentMethodID = pm.PaymentMethodID
    WHERE 
        CAST(o.OrderDate AS DATE) BETWEEN @StartDate AND @EndDate
        AND (@EmployeeID IS NULL OR o.EmployeeID = @EmployeeID)
        AND (@PaymentStatus IS NULL OR o.PaymentStatus = @PaymentStatus)
    ORDER BY 
        o.OrderDate DESC;
END
GO

-- Stored procedure to cancel order
CREATE PROCEDURE app.sp_CancelOrder
    @OrderID INT,
    @CancelReason NVARCHAR(500),
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Check if order exists and is not already cancelled
        IF NOT EXISTS (SELECT 1 FROM app.Order WHERE OrderID = @OrderID AND PaymentStatus <> 'Cancelled')
        BEGIN
            RAISERROR('Order not found or already cancelled', 16, 1);
            ROLLBACK;
            RETURN;
        END
        
        -- Get order code for logging
        DECLARE @OrderCode NVARCHAR(20);
        SELECT @OrderCode = OrderCode FROM app.Order WHERE OrderID = @OrderID;
        
        -- Update order status
        UPDATE app.Order
        SET 
            PaymentStatus = 'Cancelled',
            Note = ISNULL(Note + ' | ', '') + 'Cancelled: ' + @CancelReason,
            ModifiedDate = GETDATE()
        WHERE 
            OrderID = @OrderID;
        
        -- Return inventory items
        DECLARE @ProductID INT, @Quantity INT;
        DECLARE orderDetails_cursor CURSOR FOR
        SELECT ProductID, Quantity FROM app.OrderDetail WHERE OrderID = @OrderID;
        
        OPEN orderDetails_cursor;
        FETCH NEXT FROM orderDetails_cursor INTO @ProductID, @Quantity;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Get current inventory
            DECLARE @CurrentStock INT;
            SELECT @CurrentStock = Quantity FROM app.Inventory WHERE ProductID = @ProductID;
            
            -- Update inventory
            UPDATE app.Inventory
            SET Quantity = Quantity + @Quantity, LastUpdated = GETDATE()
            WHERE ProductID = @ProductID;
            
            -- Record inventory transaction
            INSERT INTO app.InventoryTransaction (
                ProductID, TransactionType, Quantity, PreviousQuantity, 
                CurrentQuantity, ReferenceID, ReferenceType, Note, TransactionDate
            )
            VALUES (
                @ProductID, 'Return', @Quantity, @CurrentStock, 
                @CurrentStock + @Quantity, @OrderID, 'OrderCancel', 
                'Order cancelled: ' + @CancelReason, GETDATE()
            );
            
            FETCH NEXT FROM orderDetails_cursor INTO @ProductID, @Quantity;
        END
        
        CLOSE orderDetails_cursor;
        DEALLOCATE orderDetails_cursor;
        
        -- Log the activity
        INSERT INTO app.ActivityLog (
            AccountID, ActivityType, EntityType, EntityID, Description
        )
        VALUES (
            @EmployeeID, 'Cancel', 'Order', @OrderID, 
            'Cancelled order: ' + @OrderCode + ' - Reason: ' + @CancelReason
        );
        
        COMMIT;
        
        -- Return success
        SELECT 'Order cancelled successfully' AS Result;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END
GO

PRINT 'Order management stored procedures created successfully';