-- =====================================================
-- E-COMMERCE STORE DATABASE MANAGEMENT SYSTEM
-- =====================================================
-- This database manages an online e-commerce platform with
-- customers, products, orders, payments, and shipping functionality
-- =====================================================

-- Create the database
CREATE DATABASE IF NOT EXISTS ecommerce_store;
USE ecommerce_store;

-- =====================================================
-- TABLE CREATION WITH CONSTRAINTS
-- =====================================================

-- 1. CUSTOMERS TABLE
-- Stores customer information with unique email constraint
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15),
    date_of_birth DATE,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Constraints
    CONSTRAINT chk_email_format CHECK (email LIKE '%@%.%'),
    CONSTRAINT chk_phone_length CHECK (LENGTH(phone) >= 10)
);

-- 2. CUSTOMER ADDRESSES TABLE
-- One customer can have multiple addresses (One-to-Many)
CREATE TABLE customer_addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    address_type ENUM('billing', 'shipping', 'both') NOT NULL,
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'USA',
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraint
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 3. CATEGORIES TABLE
-- Product categories with hierarchical structure
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    parent_category_id INT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Self-referencing Foreign Key for hierarchy
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id) 
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- 4. SUPPLIERS TABLE
-- Stores supplier/vendor information
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(150) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15),
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_supplier_email CHECK (email LIKE '%@%.%')
);

-- 5. PRODUCTS TABLE
-- Main products catalog
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category_id INT NOT NULL,
    supplier_id INT NOT NULL,
    sku VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    cost_price DECIMAL(10,2),
    weight DECIMAL(8,3),
    dimensions VARCHAR(50),
    stock_quantity INT NOT NULL DEFAULT 0,
    reorder_level INT DEFAULT 10,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    FOREIGN KEY (category_id) REFERENCES categories(category_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- Business Logic Constraints
    CONSTRAINT chk_price_positive CHECK (price > 0),
    CONSTRAINT chk_stock_non_negative CHECK (stock_quantity >= 0)
);

-- 6. PRODUCT IMAGES TABLE
-- Multiple images per product (One-to-Many)
CREATE TABLE product_images (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE,
    display_order INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraint
    FOREIGN KEY (product_id) REFERENCES products(product_id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 7. PRODUCT ATTRIBUTES TABLE
-- Flexible product attributes (color, size, material, etc.)
CREATE TABLE product_attributes (
    attribute_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    attribute_name VARCHAR(50) NOT NULL,
    attribute_value VARCHAR(100) NOT NULL,
    
    -- Foreign Key Constraint
    FOREIGN KEY (product_id) REFERENCES products(product_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Unique constraint to prevent duplicate attributes per product
    UNIQUE KEY unique_product_attribute (product_id, attribute_name)
);

-- 8. SHOPPING CARTS TABLE
-- Temporary storage for customer selections
CREATE TABLE shopping_carts (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraint
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 9. CART ITEMS TABLE
-- Items in shopping cart (Many-to-Many relationship between carts and products)
CREATE TABLE cart_items (
    cart_item_id INT AUTO_INCREMENT PRIMARY KEY,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    FOREIGN KEY (cart_id) REFERENCES shopping_carts(cart_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Business Logic Constraints
    CONSTRAINT chk_quantity_positive CHECK (quantity > 0),
    
    -- Unique constraint to prevent duplicate products in same cart
    UNIQUE KEY unique_cart_product (cart_id, product_id)
);

-- 10. ORDERS TABLE
-- Customer orders with status tracking
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_number VARCHAR(20) NOT NULL UNIQUE,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'returned') 
        DEFAULT 'pending',
    subtotal DECIMAL(12,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    shipping_cost DECIMAL(8,2) DEFAULT 0.00,
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    total_amount DECIMAL(12,2) NOT NULL,
    billing_address_id INT,
    shipping_address_id INT,
    special_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (billing_address_id) REFERENCES customer_addresses(address_id) 
        ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (shipping_address_id) REFERENCES customer_addresses(address_id) 
        ON DELETE SET NULL ON UPDATE CASCADE,
    
    -- Business Logic Constraints
    CONSTRAINT chk_subtotal_positive CHECK (subtotal >= 0),
    CONSTRAINT chk_total_positive CHECK (total_amount >= 0)
);

-- 11. ORDER ITEMS TABLE
-- Products within each order (Many-to-Many between orders and products)
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(12,2) NOT NULL,
    
    -- Foreign Key Constraints
    FOREIGN KEY (order_id) REFERENCES orders(order_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- Business Logic Constraints
    CONSTRAINT chk_order_quantity_positive CHECK (quantity > 0),
    CONSTRAINT chk_unit_price_positive CHECK (unit_price >= 0)
);

-- 12. PAYMENT METHODS TABLE
-- Available payment options
CREATE TABLE payment_methods (
    payment_method_id INT AUTO_INCREMENT PRIMARY KEY,
    method_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    processing_fee_percentage DECIMAL(5,4) DEFAULT 0.0000,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 13. PAYMENTS TABLE
-- Payment records for orders
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method_id INT NOT NULL,
    payment_amount DECIMAL(12,2) NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed', 'refunded', 'partially_refunded') 
        DEFAULT 'pending',
    transaction_id VARCHAR(100),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    
    -- Foreign Key Constraints
    FOREIGN KEY (order_id) REFERENCES orders(order_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (payment_method_id) REFERENCES payment_methods(payment_method_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- Business Logic Constraints
    CONSTRAINT chk_payment_amount_positive CHECK (payment_amount > 0)
);

-- 14. SHIPPING CARRIERS TABLE
-- Available shipping companies
CREATE TABLE shipping_carriers (
    carrier_id INT AUTO_INCREMENT PRIMARY KEY,
    carrier_name VARCHAR(100) NOT NULL UNIQUE,
    website VARCHAR(255),
    phone VARCHAR(15),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 15. SHIPPING TABLE
-- Shipping information for orders
CREATE TABLE shipping (
    shipping_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    carrier_id INT,
    tracking_number VARCHAR(100),
    shipping_method VARCHAR(100),
    estimated_delivery_date DATE,
    actual_delivery_date DATE,
    shipping_cost DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    status ENUM('pending', 'picked_up', 'in_transit', 'out_for_delivery', 'delivered', 'exception') 
        DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    FOREIGN KEY (order_id) REFERENCES orders(order_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (carrier_id) REFERENCES shipping_carriers(carrier_id) 
        ON DELETE SET NULL ON UPDATE CASCADE,
    
    -- One-to-One relationship constraint (one shipping record per order)
    UNIQUE KEY unique_order_shipping (order_id)
);

-- 16. REVIEWS TABLE
-- Customer product reviews (Many-to-Many between customers and products)
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    order_id INT,
    rating INT NOT NULL,
    title VARCHAR(200),
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    is_approved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) 
        ON DELETE SET NULL ON UPDATE CASCADE,
    
    -- Business Logic Constraints
    CONSTRAINT chk_rating_range CHECK (rating >= 1 AND rating <= 5),
    
    -- Prevent multiple reviews per customer per product
    UNIQUE KEY unique_customer_product_review (customer_id, product_id)
);

-- 17. COUPONS TABLE
-- Discount coupons and promotional codes
CREATE TABLE coupons (
    coupon_id INT AUTO_INCREMENT PRIMARY KEY,
    coupon_code VARCHAR(50) NOT NULL UNIQUE,
    coupon_name VARCHAR(100) NOT NULL,
    description TEXT,
    discount_type ENUM('percentage', 'fixed_amount') NOT NULL,
    discount_value DECIMAL(10,2) NOT NULL,
    minimum_order_amount DECIMAL(10,2) DEFAULT 0.00,
    max_discount_amount DECIMAL(10,2),
    usage_limit INT,
    used_count INT DEFAULT 0,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Business Logic Constraints
    CONSTRAINT chk_discount_value_positive CHECK (discount_value > 0),
    CONSTRAINT chk_end_date_after_start CHECK (end_date >= start_date),
    CONSTRAINT chk_usage_limit_positive CHECK (usage_limit IS NULL OR usage_limit > 0)
);

-- 18. ORDER COUPONS TABLE
-- Track coupon usage in orders (Many-to-Many)
CREATE TABLE order_coupons (
    order_coupon_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    coupon_id INT NOT NULL,
    discount_applied DECIMAL(10,2) NOT NULL,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    FOREIGN KEY (order_id) REFERENCES orders(order_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (coupon_id) REFERENCES coupons(coupon_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- Prevent same coupon being applied multiple times to same order
    UNIQUE KEY unique_order_coupon (order_id, coupon_id)
);

-- =====================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- =====================================================

-- Customer indexes
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_last_name ON customers(last_name);

-- Product indexes
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_supplier ON products(supplier_id);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_name ON products(product_name);

-- Order indexes
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_number ON orders(order_number);

-- Order items indexes
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- Review indexes
CREATE INDEX idx_reviews_product ON reviews(product_id);
CREATE INDEX idx_reviews_customer ON reviews(customer_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- Payment indexes
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_status ON payments(payment_status);

-- =====================================================
-- SAMPLE DATA INSERTION
-- =====================================================

-- Insert Categories
INSERT INTO categories (category_name, description) VALUES
('Electronics', 'Electronic devices and accessories'),
('Computers', 'Desktop and laptop computers'),
('Smartphones', 'Mobile phones and accessories'),
('Home & Garden', 'Home improvement and garden supplies'),
('Clothing', 'Apparel and fashion accessories'),
('Books', 'Physical and digital books');

-- Insert subcategories
INSERT INTO categories (category_name, parent_category_id, description) VALUES
('Laptops', 2, 'Portable computers'),
('Desktop PCs', 2, 'Desktop computer systems'),
('Android Phones', 3, 'Android-based smartphones'),
('iPhone', 3, 'Apple iPhone products');

-- Insert Payment Methods
INSERT INTO payment_methods (method_name, description, processing_fee_percentage) VALUES
('Credit Card', 'Visa, MasterCard, American Express', 0.0290),
('PayPal', 'PayPal payment processing', 0.0310),
('Bank Transfer', 'Direct bank transfer', 0.0050),
('Cash on Delivery', 'Pay when delivered', 0.0000);

-- Insert Shipping Carriers
INSERT INTO shipping_carriers (carrier_name, website, phone) VALUES
('FedEx', 'https://www.fedex.com', '1-800-463-3339'),
('UPS', 'https://www.ups.com', '1-800-742-5877'),
('USPS', 'https://www.usps.com', '1-800-275-8777'),
('DHL', 'https://www.dhl.com', '1-800-225-5345');

-- Insert Sample Suppliers
INSERT INTO suppliers (company_name, contact_person, email, phone, city, country) VALUES
('TechWorld Distributors', 'John Smith', 'john@techworld.com', '555-0101', 'San Francisco', 'USA'),
('Global Electronics Ltd', 'Sarah Johnson', 'sarah@globalelec.com', '555-0102', 'New York', 'USA'),
('Fashion Forward Inc', 'Mike Brown', 'mike@fashionforward.com', '555-0103', 'Los Angeles', 'USA');

-- Insert Sample Customers
INSERT INTO customers (first_name, last_name, email, phone, date_of_birth) VALUES
('Alice', 'Johnson', 'alice.johnson@email.com', '555-1234', '1990-05-15'),
('Bob', 'Smith', 'bob.smith@email.com', '555-5678', '1985-08-22'),
('Carol', 'Williams', 'carol.williams@email.com', '555-9012', '1992-12-03');

-- Insert Customer Addresses
INSERT INTO customer_addresses (customer_id, address_type, street_address, city, state, postal_code, is_default) VALUES
(1, 'both', '123 Main Street', 'Anytown', 'CA', '90210', TRUE),
(2, 'billing', '456 Oak Avenue', 'Springfield', 'IL', '62701', TRUE),
(2, 'shipping', '789 Pine Road', 'Springfield', 'IL', '62702', FALSE),
(3, 'both', '321 Elm Street', 'Portland', 'OR', '97201', TRUE);

-- Insert Sample Products
INSERT INTO products (product_name, category_id, supplier_id, sku, description, price, cost_price, stock_quantity, reorder_level) VALUES
('MacBook Pro 16-inch', 7, 1, 'APPLE-MBP16-001', 'Apple MacBook Pro with M2 chip, 16-inch display', 2499.00, 2200.00, 15, 5),
('Dell XPS 13', 7, 2, 'DELL-XPS13-001', 'Dell XPS 13 laptop with Intel i7 processor', 1299.00, 1100.00, 25, 10),
('iPhone 14 Pro', 10, 1, 'APPLE-IP14P-001', 'Apple iPhone 14 Pro, 128GB, Space Black', 999.00, 850.00, 50, 20),
('Samsung Galaxy S23', 9, 2, 'SAMSUNG-GS23-001', 'Samsung Galaxy S23, 256GB, Phantom Black', 799.00, 650.00, 35, 15);

-- Insert Product Attributes
INSERT INTO product_attributes (product_id, attribute_name, attribute_value) VALUES
(1, 'Color', 'Space Gray'),
(1, 'Storage', '512GB SSD'),
(1, 'RAM', '16GB'),
(2, 'Color', 'Silver'),
(2, 'Storage', '256GB SSD'),
(2, 'RAM', '8GB'),
(3, 'Color', 'Space Black'),
(3, 'Storage', '128GB'),
(4, 'Color', 'Phantom Black'),
(4, 'Storage', '256GB');

-- Insert Sample Coupons
INSERT INTO coupons (coupon_code, coupon_name, description, discount_type, discount_value, minimum_order_amount, start_date, end_date, usage_limit) VALUES
('SAVE10', '10% Off Everything', 'Get 10% off your entire order', 'percentage', 10.00, 100.00, '2024-01-01', '2024-12-31', 1000),
('WELCOME50', 'Welcome Discount', '$50 off your first order', 'fixed_amount', 50.00, 200.00, '2024-01-01', '2024-12-31', 500);

-- =====================================================
-- VIEWS FOR COMMON QUERIES
-- =====================================================

-- View: Product catalog with category information
CREATE VIEW product_catalog AS
SELECT 
    p.product_id,
    p.product_name,
    p.sku,
    c.category_name,
    s.company_name as supplier_name,
    p.price,
    p.stock_quantity,
    p.is_active
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN suppliers s ON p.supplier_id = s.supplier_id;

-- View: Order summary with customer information
CREATE VIEW order_summary AS
SELECT 
    o.order_id,
    o.order_number,
    CONCAT(cu.first_name, ' ', cu.last_name) as customer_name,
    cu.email,
    o.order_date,
    o.status,
    o.total_amount,
    COUNT(oi.order_item_id) as total_items
FROM orders o
JOIN customers cu ON o.customer_id = cu.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_number, customer_name, cu.email, o.order_date, o.status, o.total_amount;

-- =====================================================
-- STORED PROCEDURES
-- =====================================================

DELIMITER //

-- Procedure: Add product to cart
CREATE PROCEDURE AddToCart(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE cart_id_var INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Get or create cart for customer
    SELECT cart_id INTO cart_id_var 
    FROM shopping_carts 
    WHERE customer_id = p_customer_id 
    LIMIT 1;
    
    IF cart_id_var IS NULL THEN
        INSERT INTO shopping_carts (customer_id) VALUES (p_customer_id);
        SET cart_id_var = LAST_INSERT_ID();
    END IF;
    
    -- Add or update cart item
    INSERT INTO cart_items (cart_id, product_id, quantity)
    VALUES (cart_id_var, p_product_id, p_quantity)
    ON DUPLICATE KEY UPDATE 
        quantity = quantity + p_quantity,
        added_at = CURRENT_TIMESTAMP;
    
    COMMIT;
END //

-- Procedure: Calculate order total
CREATE PROCEDURE CalculateOrderTotal(
    IN p_order_id INT,
    OUT p_subtotal DECIMAL(12,2),
    OUT p_total DECIMAL(12,2)
)
BEGIN
    SELECT 
        SUM(total_price),
        SUM(total_price) + COALESCE((SELECT tax_amount FROM orders WHERE order_id = p_order_id), 0) 
                         + COALESCE((SELECT shipping_cost FROM orders WHERE order_id = p_order_id), 0)
                         - COALESCE((SELECT discount_amount FROM orders WHERE order_id = p_order_id), 0)
    INTO p_subtotal, p_total
    FROM order_items 
    WHERE order_id = p_order_id;
END //

DELIMITER ;

-- =====================================================
-- TRIGGERS FOR DATA INTEGRITY
-- =====================================================

DELIMITER //

-- Trigger: Update product stock when order item is added
CREATE TRIGGER tr_update_stock_on_order
    AFTER INSERT ON order_items
    FOR EACH ROW
BEGIN
    UPDATE products 
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
END //

-- Trigger: Restore stock when order is cancelled
CREATE TRIGGER tr_restore_stock_on_cancel
    AFTER UPDATE ON orders
    FOR EACH ROW
BEGIN
    IF OLD.status != 'cancelled' AND NEW.status = 'cancelled' THEN
        UPDATE products p
        INNER JOIN order_items oi ON p.product_id = oi.product_id
        SET p.stock_quantity = p.stock_quantity + oi.quantity
        WHERE oi.order_id = NEW.order_id;
    END IF;
END //

-- Trigger: Update coupon usage count
CREATE TRIGGER tr_update_coupon_usage
    AFTER INSERT ON order_coupons
    FOR EACH ROW
BEGIN
    UPDATE coupons 
    SET used_count = used_count + 1 
    WHERE coupon_id = NEW.coupon_id;
END //

DELIMITER ;

-- =====================================================
-- DATABASE DOCUMENTATION COMPLETE
-- =====================================================

-- This database includes:
-- ✓ Well-structured tables with proper normalization
-- ✓ PRIMARY KEY constraints on all tables
-- ✓ FOREIGN KEY constraints maintaining referential integrity
-- ✓ One-to-One relationships (orders ↔ shipping)
-- ✓ One-to-Many relationships (customers → addresses, products → images)
-- ✓ Many-to-Many relationships (customers ↔ products via reviews, orders ↔ coupons)
-- ✓ CHECK constraints for business logic validation
-- ✓ UNIQUE constraints preventing duplicate data
-- ✓ NOT NULL constraints for required fields
-- ✓ Default values and auto-increment fields
-- ✓ Indexes for query performance optimization
-- ✓ Views for common reporting needs
-- ✓ Stored procedures for complex operations
-- ✓ Triggers for automatic data maintenance
-- ✓ Sample data for testing

-- Total Tables: 18 tables covering all aspects of e-commerce operations
-- Relationships: All major relationship types implemented
-- Constraints: Comprehensive data validation and integrity rules