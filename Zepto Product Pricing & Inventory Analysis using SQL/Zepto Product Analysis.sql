-- list all databases
SHOW DATABASES;

-- create a new database
CREATE DATABASE datasets;

-- use the database
USE datasets;

-- show tables inside the database
SHOW TABLES;

-- delete table if it already exists
DROP TABLE IF EXISTS zepto;

-- create zepto table to store product data
CREATE TABLE zepto1 (
    sku_id SERIAL PRIMARY KEY,      -- unique product id
    category VARCHAR(120),           -- product category
    name VARCHAR(150) NOT NULL,      -- product name
    mrp NUMERIC(8,2),                -- maximum retail price
    discountPercent NUMERIC(5,2),    -- discount percentage
    availableQuantity INTEGER,       -- available stock count
    discountedSellingPrice NUMERIC(8,2), -- price after discount
    weightInGms INTEGER,             -- product weight in grams
    outOfStock BOOLEAN,              -- stock availability
    quantity INTEGER                 -- quantity per pack
);



-- data exploration
SELECT * FROM zepto;

-- view first 10 records sorted by category
SELECT * FROM zepto ORDER BY category ASC LIMIT 10;

-- count total number of rows
SELECT COUNT(*) FROM zepto;

-- preview sample data
SELECT * FROM zepto LIMIT 10;

-- check for records containing NULL values
SELECT * FROM zepto
WHERE name IS NULL
   OR category IS NULL
   OR mrp IS NULL
   OR discountPercent IS NULL
   OR discountedSellingPrice IS NULL
   OR weightInGms IS NULL
   OR availableQuantity IS NULL
   OR outOfStock IS NULL
   OR quantity IS NULL;

-- list unique product categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;

-- count products that are in stock vs out of stock
SELECT outOfStock, COUNT(sku_id)
FROM zepto
GROUP BY outOfStock;

-- find products that appear multiple times
SELECT name, COUNT(sku_id) AS "Number of SKUs"
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY COUNT(sku_id) DESC;

-- data cleaning

-- identify products with zero price
SELECT * FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;

-- preview some zero-price products
SELECT * FROM zepto
WHERE mrp = 0
LIMIT 10;

-- convert prices from paise to rupees (initial conversion)
UPDATE zepto
SET mrp = mrp / 100.0,
    discountedSellingPrice = discountedSellingPrice / 100.0;

-- disable safe update mode temporarily
SET SQL_SAFE_UPDATES = 0;

-- convert only values still in paise (avoid double conversion)
UPDATE zepto
SET mrp = mrp / 100,
    discountedSellingPrice = discountedSellingPrice / 100
WHERE mrp > 100;

-- re-enable safe update mode
SET SQL_SAFE_UPDATES = 1;

-- verify updated prices
SELECT mrp, discountedSellingPrice FROM zepto;

-- data analysis

-- Q1. Top 10 products with highest discount
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

-- Q2. High MRP products that are out of stock
SELECT DISTINCT name, mrp
FROM zepto
WHERE outOfStock = TRUE AND mrp > 300
ORDER BY mrp DESC;

-- Q3. Estimated revenue per category
SELECT category,
SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue;

-- Q4. Premium products with low discount
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

-- Q5. Top 5 categories with highest average discount
SELECT category,
ROUND(AVG(discountPercent), 2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- Q6. Best value products based on price per gram
SELECT DISTINCT name, weightInGms, discountedSellingPrice,
ROUND(discountedSellingPrice / weightInGms, 2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

-- Q7. Categorize products by weight
SELECT DISTINCT name, weightInGms,
CASE
    WHEN weightInGms < 1000 THEN 'Low'
    WHEN weightInGms < 5000 THEN 'Medium'
    ELSE 'Bulk'
END AS weight_category
FROM zepto;

-- Q8. Total inventory weight per category
SELECT category,
SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight;
