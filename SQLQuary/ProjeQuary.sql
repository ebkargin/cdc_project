CREATE TABLE Customers (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    cust_name VARCHAR(100) NOT NULL,
    cust_email VARCHAR(100) NOT NULL
);
GO

CREATE TABLE Orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    order_product VARCHAR(100) NOT NULL,
    order_amount DECIMAL(10,2) NOT NULL,
    order_status VARCHAR(50) NOT NULL,
    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
GO

CREATE TABLE Orders_log (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    operation_type VARCHAR(10) NOT NULL,

    order_id INT NOT NULL,
    customer_id INT NOT NULL,

    old_order_product VARCHAR(100),
    old_order_amount DECIMAL(10,2),
    old_order_status VARCHAR(50),

    new_order_product VARCHAR(100),
    new_order_amount DECIMAL(10,2),
    new_order_status VARCHAR(50),

    changed_at DATETIME NOT NULL DEFAULT GETDATE(),
    is_processed BIT NOT NULL DEFAULT 0
);
GO

CREATE TRIGGER trg_orders_cdc
ON Orders
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- DELETE
    INSERT INTO Orders_log (
        operation_type,
        order_id,
        customer_id,
        old_order_product,
        old_order_amount,
        old_order_status
    )
    SELECT
        'DELETE',
        d.order_id,
        d.customer_id,
        d.order_product,
        d.order_amount,
        d.order_status
    FROM deleted d
    LEFT JOIN inserted i ON d.order_id = i.order_id
    WHERE i.order_id IS NULL;

    -- INSERT
    INSERT INTO Orders_log (
        operation_type,
        order_id,
        customer_id,
        new_order_product,
        new_order_amount,
        new_order_status
    )
    SELECT
        'INSERT',
        i.order_id,
        i.customer_id,
        i.order_product,
        i.order_amount,
        i.order_status
    FROM inserted i
    LEFT JOIN deleted d ON i.order_id = d.order_id
    WHERE d.order_id IS NULL;

    -- UPDATE
    INSERT INTO Orders_log (
        operation_type,
        order_id,
        customer_id,
        old_order_product,
        old_order_amount,
        old_order_status,
        new_order_product,
        new_order_amount,
        new_order_status
    )
    SELECT
        'UPDATE',
        i.order_id,
        i.customer_id,
        d.order_product,
        d.order_amount,
        d.order_status,
        i.order_product,
        i.order_amount,
        i.order_status
    FROM inserted i
    INNER JOIN deleted d ON i.order_id = d.order_id;
END;
GO
