SET search_path TO olist;


-- PRODUCT PERFORMANCE

-- Which products generate the highest total revenue?
SELECT
    p.product_id,
    SUM(oi.price) AS total_revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id
ORDER BY total_revenue DESC;

-- Which products sell the highest number of units?
SELECT
    p.product_id,
    COUNT(*) AS units_sold
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id
ORDER BY units_sold DESC;

-- Which products have the highest average selling price?
SELECT
    p.product_id,
    ROUND(AVG(oi.price), 2) AS average_selling_price
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id
ORDER BY average_selling_price DESC;

-- Which products are included in the highest number of orders?
SELECT
    p.product_id,
    COUNT(DISTINCT oi.order_id) AS order_count
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id
ORDER BY order_count DESC;


-- PRODUCT CATEGORY PERFORMANCE

-- Which product categories generate the highest total revenue?
SELECT
    p.product_category_name,
    SUM(oi.price) AS total_revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC

-- Which product categories sell the highest number of units?
SELECT
    p.product_category_name,
    COUNT(*) AS units_sold
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY units_sold DESC;

-- Which product categories have the highest average selling price?
SELECT
    p.product_category_name,
    ROUND(AVG(oi.price), 2) AS average_selling_price
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY average_selling_price DESC;

-- Which product categories have the highest number of orders?
SELECT
    p.product_category_name,
    COUNT(DISTINCT oi.order_id) AS order_count
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY order_count DESC;


-- PRODUCT CATEGORY REVENUE & SALES SHARE

-- What percentage of total revenue comes from each product category?

-- What percentage of total units sold comes from each product category?

-- Which categories have high sales volume but relatively low revenue?

-- Which categories have high revenue but relatively low sales volume?


-- PRODUCT REVIEWS & CUSTOMER SATISFACTION

-- Which product categories have the highest average review score?

-- Which product categories have the lowest average review score?

-- Which products have the highest average review scores?

-- Which products receive the most reviews?

-- Do the best-selling products also receive high review scores?


-- PRODUCT CHARACTERISTICS

-- What is the average product weight by category?

-- What is the average product volume by category?

-- Which categories contain the heaviest products?

-- Which categories contain the largest products?


-- SELLER PRODUCT PERFORMANCE

-- Which sellers generate the highest product revenue?

-- Which sellers sell the highest number of items?

-- Which sellers have the largest product assortment?

-- Which product categories are offered by the most sellers?


-- PRODUCT PERFORMANCE OVER TIME

-- How does category revenue change over time?

-- Which product categories generate the highest revenue each year?

-- Which product categories sell the most units each year?


-- TOP PRODUCT & CATEGORY RANKINGS

-- What are the top 10 products by revenue?

-- What are the top 10 products by units sold?

-- What are the top 10 product categories by revenue?

-- What are the top 10 product categories by units sold?


-- PRODUCT BUSINESS INSIGHTS

-- Which product categories are the strongest overall performers?

-- Which categories have high demand but relatively low revenue?

-- Which categories have high revenue but relatively low demand?

-- Are the best-selling products also the highest-revenue products?

-- Are highly reviewed products also among the best-selling products?
