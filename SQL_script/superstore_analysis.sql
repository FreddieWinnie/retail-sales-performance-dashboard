CREATE DATABASE retail_sales_analysis;
USE retail_sales_analysis;

SELECT COUNT(*) 
FROM orders;

SELECT *
FROM orders
LIMIT 5;

DESCRIBE orders;

SELECT `Ship Date`,`Order Date`
FROM orders
LIMIT 5;

UPDATE orders
SET `Order Date` = STR_TO_DATE(`Order Date`, '%m/%d/%Y');

ALTER TABLE orders
MODIFY COLUMN `Order Date` DATE;

UPDATE orders
SET `Ship Date` = STR_TO_DATE(`Ship Date`, '%m/%d/%Y');

ALTER TABLE orders
MODIFY COLUMN `Ship Date` DATE;

CREATE TABLE orders_backup AS
SELECT *
FROM orders;

ALTER TABLE orders RENAME COLUMN `Order ID` TO order_id;
ALTER TABLE orders RENAME COLUMN `Order Date` TO order_date;
ALTER TABLE orders RENAME COLUMN Quarter TO quarter;
ALTER TABLE orders RENAME COLUMN order_month TO order_month;
ALTER TABLE orders RENAME COLUMN Month_number TO month_number;
ALTER TABLE orders RENAME COLUMN order_year TO order_year;
ALTER TABLE orders RENAME COLUMN `Ship Date` TO ship_date;
ALTER TABLE orders RENAME COLUMN `Customer ID` TO customer_id;
ALTER TABLE orders RENAME COLUMN `Customer Name` TO customer_name;
ALTER TABLE orders RENAME COLUMN Segment TO segment;
ALTER TABLE orders RENAME COLUMN `Country/Region` TO country;
ALTER TABLE orders RENAME COLUMN City TO city;
ALTER TABLE orders RENAME COLUMN `State/Province` TO state;
ALTER TABLE orders RENAME COLUMN `Postal Code` TO postal_code;
ALTER TABLE orders RENAME COLUMN Region TO region;
ALTER TABLE orders RENAME COLUMN `Product ID` TO product_id;
ALTER TABLE orders RENAME COLUMN Category TO category;
ALTER TABLE orders RENAME COLUMN `Sub-Category` TO sub_category;
ALTER TABLE orders RENAME COLUMN `Product Name` TO product_name;
ALTER TABLE orders RENAME COLUMN Sales TO sales;
ALTER TABLE orders RENAME COLUMN Quantity TO quantity;
ALTER TABLE orders RENAME COLUMN Discount TO discount;
ALTER TABLE orders RENAME COLUMN Discount_groups TO discount_group;
ALTER TABLE orders RENAME COLUMN Profit TO profit;








































