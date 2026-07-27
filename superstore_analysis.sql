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










































