# E-commerce Store Database Management System

## 📋 Project Overview

This project implements a comprehensive relational database management system for an e-commerce platform. The database is designed to handle all aspects of online retail operations including customer management, product catalog, order processing, payments, shipping, and marketing features.

## 🗂️ Database Schema

### **Core Entities (18 Tables)**

#### **Customer Management**
- `customers` - Customer personal information and account details
- `customer_addresses` - Multiple shipping/billing addresses per customer

#### **Product Catalog**
- `products` - Main product information with pricing and inventory
- `categories` - Hierarchical product categorization system
- `suppliers` - Vendor/supplier information
- `product_images` - Multiple images per product
- `product_attributes` - Flexible product specifications (color, size, etc.)

#### **Shopping Experience**
- `shopping_carts` - Customer shopping cart sessions
- `cart_items` - Products added to shopping carts
- `reviews` - Customer product reviews and ratings

#### **Order Management**
- `orders` - Customer orders with status tracking
- `order_items` - Individual products within orders
- `order_coupons` - Applied discount coupons per order

#### **Payment Processing**
- `payments` - Payment transaction records
- `payment_methods` - Available payment options

#### **Shipping & Logistics**
- `shipping` - Shipment tracking and delivery information
- `shipping_carriers` - Available shipping companies

#### **Marketing**
- `coupons` - Discount codes and promotional offers

## 🔗 Relationship Types Implemented

### **One-to-One Relationships**
- `orders` ↔ `shipping` (Each order has exactly one shipment record)

### **One-to-Many Relationships**
- `customers` → `customer_addresses` (One customer, multiple addresses)
- `customers` → `orders` (One customer, multiple orders)
- `products` → `product_images` (One product, multiple images)
- `products` → `product_attributes` (One product, multiple attributes)
- `categories` → `categories` (Self-referencing for subcategories)
- `orders` → `order_items` (One order, multiple items)
- `suppliers` → `products` (One supplier, multiple products)

### **Many-to-Many Relationships**
- `customers` ↔ `products` (via `reviews` table)
- `orders` ↔ `coupons` (via `order_coupons` table)
- `shopping_carts` ↔ `products` (via `cart_items` table)

## 🔒 Constraints & Data Integrity

### **Primary Keys**
- Auto-incrementing INTEGER primary keys on all tables
- Ensures unique identification of all records

### **Foreign Keys**
- Comprehensive referential integrity across all related tables
- Cascade operations for dependent data management
- Restrict operations to prevent orphaned critical business data

### **Unique Constraints**
- Customer email addresses
- Product SKUs
- Order numbers
- Coupon codes
- Supplier emails

### **Check Constraints**
- Price validation (must be positive)
- Stock quantity validation (non-negative)
- Rating validation (1-5 scale)
- Email format validation
- Date range validation for coupons

### **Not Null Constraints**
- Critical business fields marked as required
- Ensures data completeness for essential operations

## ⚡ Performance Features

### **Indexes**
- Customer email and name lookups
- Product category and supplier searches
- Order date and status filtering
- Payment status tracking
- Review product associations

### **Views**
- `product_catalog` - Complete product information with categories
- `order_summary` - Order details with customer information

### **Stored Procedures**
- `AddToCart()` - Add products to customer shopping cart
- `CalculateOrderTotal()` - Calculate order subtotals and totals

### **Triggers**
- Automatic stock quantity updates on orders
- Stock restoration on order cancellation
- Coupon usage counter maintenance

## 📊 Sample Data Included

The database comes pre-populated with sample data for testing:
- 3 customers with addresses
- 4 products across different categories
- 2 promotional coupons
- 4 shipping carriers
- 4 payment methods
- Hierarchical product categories

## 🚀 Installation & Setup

### **Prerequisites**
- MySQL Server 8.0 or higher
- MySQL Workbench (recommended) or command-line client

### **Installation Steps**

1. **Open MySQL Client**
   ```bash
   mysql -u root -p
   ```

2. **Execute the Script**
   ```sql
   source /path/to/ecommerce_store.sql
   ```
   
   Or in MySQL Workbench:
   - Open the `ecommerce_store.sql` file
   - Click "Execute" button

3. **Verify Installation**
   ```sql
   USE ecommerce_store;
   SHOW TABLES;
   ```

## 📈 Usage Examples

### **Basic Queries**

**View all products with categories:**
```sql
SELECT * FROM product_catalog;
```

**Get customer order history:**
```sql
SELECT * FROM order_summary WHERE customer_name = 'Alice Johnson';
```

**Check low stock products:**
```sql
SELECT product_name, stock_quantity 
FROM products 
WHERE stock_quantity <= reorder_level;
```

### **Using Stored Procedures**

**Add product to customer cart:**
```sql
CALL AddToCart(1, 1, 2); -- Customer 1, Product 1, Quantity 2
```

**Calculate order totals:**
```sql
CALL CalculateOrderTotal(1, @subtotal, @total);
SELECT @subtotal, @total;
```

## 🏗️ Database Design Principles

### **Normalization**
- Designed to 3rd Normal Form (3NF)
- Eliminates data redundancy
- Ensures data consistency

### **Scalability**
- Indexed for performance
- Designed to handle large datasets
- Optimized query patterns

### **Business Logic**
- Real-world e-commerce requirements
- Flexible attribute system
- Comprehensive order workflow

### **Data Integrity**
- Referential integrity maintained
- Business rule validation
- Automatic data maintenance via triggers

## 🔧 Advanced Features

### **Hierarchical Categories**
- Self-referencing category structure
- Support for unlimited category depth
- Easy navigation and filtering

### **Flexible Product Attributes**
- Dynamic product specifications
- Support for any attribute type
- Extensible without schema changes

### **Multi-Address Support**
- Separate billing and shipping addresses
- Default address management
- Address type validation

### **Order Status Workflow**
- Complete order lifecycle tracking
- Status-based business logic
- Automated inventory management

### **Coupon System**
- Percentage and fixed amount discounts
- Usage limits and tracking
- Minimum order requirements
- Date-based validity

## 📋 Table Summary

| Table Name | Records | Purpose |
|------------|---------|---------|
| customers | 3 | Customer accounts |
| customer_addresses | 4 | Customer addresses |
| categories | 10 | Product categories |
| suppliers | 3 | Product suppliers |
| products | 4 | Product catalog |
| product_attributes | 8 | Product specifications |
| payment_methods | 4 | Payment options |
| shipping_carriers | 4 | Shipping companies |
| coupons | 2 | Promotional codes |

## 🛡️ Security Considerations

- Sensitive data properly constrained
- Email validation implemented
- Foreign key constraints prevent orphaned records
- Triggers maintain data consistency
- Views provide controlled data access

## 🔄 Maintenance

### **Regular Tasks**
- Monitor stock levels using reorder_level field
- Archive old orders and reviews
- Update coupon expiration dates
- Maintain shipping carrier information

### **Performance Monitoring**
- Monitor index usage
- Review slow query logs
- Optimize based on usage patterns

## 📞 Support

This database system is designed for educational purposes and demonstrates enterprise-level database design principles. For questions or modifications, refer to the comprehensive comments within the SQL file.

## 📄 License

This project is created for academic purposes. Feel free to use and modify for educational projects.

---

**Database Version:** 1.0  
**MySQL Compatibility:** 8.0+  
**Last Updated:** September 2025  
**Total Tables:** 18  
**Total Constraints:** 50+  
**Sample Records:** 50+
