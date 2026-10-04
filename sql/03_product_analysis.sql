SET search_path TO olist;


-- PRODUCT PERFORMANCE

-- Which products generate the highest total revenue?
SELECT
    product_id,
    SUM(price) AS total_revenue
FROM order_items
GROUP BY product_id
ORDER BY total_revenue DESC;

-- Which products sell the highest number of units?
SELECT
    product_id,
    COUNT(*) AS units_sold
FROM order_items
GROUP BY product_id
ORDER BY units_sold DESC;

-- Which products have the highest average selling price?
SELECT
    product_id,
    ROUND(AVG(price), 2) AS average_selling_price
FROM order_items
GROUP BY product_id
ORDER BY average_selling_price DESC;

-- Which products are included in the highest number of orders?
SELECT
    product_id,
    COUNT(DISTINCT order_id) AS order_count
FROM order_items
GROUP BY product_id
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
ORDER BY total_revenue DESC;

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
SELECT
    p.product_category_name,
    ROUND(
        100.0 * SUM(oi.price) / (SELECT SUM(price) FROM order_items),
        2
    ) AS revenue_percentage
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY revenue_percentage DESC;

-- What percentage of total units sold comes from each product category?
SELECT
    p.product_category_name,
    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM order_items),
        2
    ) AS units_sold_percentage
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY units_sold_percentage DESC;


-- PRODUCT REVIEWS & CUSTOMER SATISFACTION

-- Which product categories have the highest average review score?
WITH category_reviews AS (
    SELECT DISTINCT
        oi.order_id,
        p.product_category_name,
        r.review_score
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    JOIN order_reviews r
        ON oi.order_id = r.order_id
)
SELECT
    product_category_name,
    ROUND(AVG(review_score), 2) AS average_review_score
FROM category_reviews
GROUP BY product_category_name
ORDER BY average_review_score DESC;

-- Which products have the highest average review scores?
WITH product_reviews AS (
    SELECT DISTINCT
        oi.order_id,
        oi.product_id,
        r.review_score
    FROM order_items oi
    JOIN order_reviews r
        ON oi.order_id = r.order_id
)
SELECT
    product_id,
    ROUND(AVG(review_score), 2) AS average_review_score
FROM product_reviews
GROUP BY product_id
ORDER BY average_review_score DESC;

-- Which products receive the most reviews?
SELECT
    oi.product_id,
    COUNT(DISTINCT r.review_id) AS review_count
FROM order_items oi
JOIN order_reviews r
    ON oi.order_id = r.order_id
GROUP BY oi.product_id
ORDER BY review_count DESC;

-- Do the best-selling products also receive high review scores?
WITH product_sales AS (
    SELECT
        product_id,
        COUNT(*) AS units_sold
    FROM order_items
    GROUP BY product_id
),
product_reviews AS (
    SELECT DISTINCT
        oi.order_id,
        oi.product_id,
        r.review_score
    FROM order_items oi
    JOIN order_reviews r
        ON oi.order_id = r.order_id
)
SELECT
    product_sales.product_id,
    product_sales.units_sold,
    ROUND(AVG(product_reviews.review_score), 2) AS average_review_score
FROM product_sales
JOIN product_reviews
    ON product_sales.product_id = product_reviews.product_id
GROUP BY
    product_sales.product_id,
    product_sales.units_sold
ORDER BY product_sales.units_sold DESC;


-- PRODUCT CHARACTERISTICS

-- What is the average product weight by category?
SELECT
    product_category_name,
    ROUND(AVG(product_weight_g), 2) AS avg_weight_g
FROM products
GROUP BY product_category_name
ORDER BY avg_weight_g DESC;

-- What is the average product volume by category?
SELECT
    product_category_name,
    ROUND(
        AVG(product_length_cm * product_height_cm * product_width_cm),
        2
    ) AS avg_volume_cm3
FROM products
GROUP BY product_category_name
ORDER BY avg_volume_cm3 DESC;


-- SELLER PRODUCT PERFORMANCE

-- Which sellers generate the highest product revenue?
SELECT
    seller_id,
    SUM(price) AS total_revenue
FROM order_items
GROUP BY seller_id
ORDER BY total_revenue DESC;

-- Which sellers sell the highest number of items?
SELECT
    seller_id,
    COUNT(*) AS items_sold
FROM order_items
GROUP BY seller_id
ORDER BY items_sold DESC;

-- Which sellers have the largest product assortment?
SELECT
    seller_id,
    COUNT(DISTINCT product_id) AS unique_products
FROM order_items
GROUP BY seller_id
ORDER BY unique_products DESC;

-- Which product categories are offered by the most sellers?
SELECT
    p.product_category_name,
    COUNT(DISTINCT oi.seller_id) AS seller_count
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY seller_count DESC;


-- PRODUCT PERFORMANCE OVER TIME

-- How does category revenue change over time?
SELECT
    TO_CHAR(o.order_purchase_timestamp, 'Mon YYYY') AS month,
    p.product_category_name,
    SUM(oi.price) AS total_revenue
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    DATE_TRUNC('month', o.order_purchase_timestamp),
    p.product_category_name
ORDER BY
    DATE_TRUNC('month', o.order_purchase_timestamp),
    total_revenue DESC;

-- Which product categories generate the highest revenue each year?
SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    p.product_category_name,
    SUM(oi.price) AS total_revenue
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    year,
    p.product_category_name
ORDER BY
    year,
    total_revenue DESC;

-- Which product categories sell the most units each year?
SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    p.product_category_name,
    COUNT(*) AS units_sold
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    year,
    p.product_category_name
ORDER BY
    year,
    units_sold DESC;


-- TOP PRODUCT & CATEGORY RANKINGS

-- What are the top 10 products by revenue?
SELECT
    product_id,
    SUM(price) AS total_revenue
FROM order_items
GROUP BY product_id
ORDER BY total_revenue DESC
LIMIT 10;

-- What are the top 10 products by units sold?
SELECT
    product_id,
    COUNT(*) AS units_sold
FROM order_items
GROUP BY product_id
ORDER BY units_sold DESC
LIMIT 10;

-- What are the top 10 product categories by revenue?
SELECT
    p.product_category_name,
    SUM(oi.price) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 10;

-- What are the top 10 product categories by units sold?
SELECT
    p.product_category_name,
    COUNT(*) AS units_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY units_sold DESC
LIMIT 10;


-- PRODUCT BUSINESS INSIGHTS

-- Which product categories combine high sales volume and high revenue?
WITH category_metrics AS (
    SELECT
        p.product_category_name,
        COUNT(*) AS units_sold,
        SUM(oi.price) AS total_revenue
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY p.product_category_name
)
SELECT
    product_category_name,
    units_sold,
    total_revenue,
    RANK() OVER (ORDER BY units_sold DESC) AS sales_rank,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM category_metrics
ORDER BY sales_rank;
