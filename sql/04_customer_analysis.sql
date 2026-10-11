SET search_path TO olist;


-- CUSTOMER OVERVIEW

-- How many unique customers have placed orders?
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM orders;

-- How many orders does each customer place on average?
SELECT ROUND(AVG(order_count), 2) AS avg_orders_per_customer
FROM (
    SELECT c.customer_unique_id, COUNT(*) AS order_count
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
) AS customer_orders;

-- How many customers have placed more than one order?
SELECT COUNT(*) AS repeat_customers
FROM (
    SELECT c.customer_unique_id
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(*) > 1
) AS repeat_customers;

-- What percentage of customers are repeat customers?
SELECT
    ROUND(
        COUNT(*) FILTER (WHERE order_count > 1) * 100.0
        / COUNT(*),
        2
    ) AS repeat_customer_percentage
FROM (
    SELECT c.customer_unique_id, COUNT(*) AS order_count
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
) AS customer_orders;


-- CUSTOMER SPENDING & ORDER VALUE

-- Which customers generate the highest total revenue?
SELECT
    c.customer_unique_id,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY total_revenue DESC;

-- Which customers place the highest number of orders?
SELECT
    c.customer_unique_id,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC;

-- Which customers have the highest average order value?
SELECT
    c.customer_unique_id,
    ROUND(AVG(order_totals.order_value), 2) AS avg_order_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN (
    SELECT
        order_id,
        SUM(price) AS order_value
    FROM order_items
    GROUP BY order_id
) AS order_totals
    ON o.order_id = order_totals.order_id
GROUP BY c.customer_unique_id
ORDER BY avg_order_value DESC;

-- What is the average total spending per customer?
SELECT
    ROUND(AVG(customer_spending), 2) AS avg_spending_per_customer
FROM (
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS customer_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
) AS customer_totals;

-- How is customer spending distributed across customers?
SELECT
    ROUND(MIN(customer_spending), 2) AS min_spending,
    ROUND(MAX(customer_spending), 2) AS max_spending,
    ROUND(AVG(customer_spending), 2) AS avg_spending,
    ROUND(
        CAST(
            PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY customer_spending)
            AS NUMERIC
        ), 2
    ) AS median_spending,
    ROUND(CAST(STDDEV(customer_spending) AS NUMERIC), 2) AS std_spending
FROM (
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS customer_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
) AS customer_totals;


-- CUSTOMER RETENTION & REPEAT PURCHASES

-- What percentage of customers make only one purchase?
SELECT
    ROUND(
        COUNT(*) FILTER (WHERE order_count = 1) * 100.0
        / COUNT(*),
        2
    ) AS one_time_customer_percentage
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
) AS customer_orders;

-- What percentage of customers make multiple purchases?
SELECT
    ROUND(
        COUNT(*) FILTER (WHERE order_count > 1) * 100.0
        / COUNT(*),
        2
    ) AS repeat_customer_percentage
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
) AS customer_orders;

-- How many orders do repeat customers place on average?
SELECT
    ROUND(AVG(order_count), 2) AS avg_orders_per_repeat_customer
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(o.order_id) > 1
) AS repeat_customers;

-- How much revenue comes from repeat customers?
SELECT
    ROUND(SUM(oi.price), 2) AS repeat_customer_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE c.customer_unique_id IN (
    SELECT
        c2.customer_unique_id
    FROM customers c2
    JOIN orders o2
        ON c2.customer_id = o2.customer_id
    GROUP BY c2.customer_unique_id
    HAVING COUNT(o2.order_id) > 1
);

-- How much revenue comes from one-time customers?
SELECT
    ROUND(SUM(oi.price), 2) AS one_time_customer_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE c.customer_unique_id IN (
    SELECT
        c2.customer_unique_id
    FROM customers c2
    JOIN orders o2
        ON c2.customer_id = o2.customer_id
    GROUP BY c2.customer_unique_id
    HAVING COUNT(o2.order_id) = 1
);

-- How does the average spending of repeat customers compare with one-time customers?
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time customers'
        ELSE 'Repeat customers'
    END AS customer_type,
    ROUND(AVG(customer_spending), 2) AS avg_spending
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(oi.price) AS customer_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
) AS customer_totals
GROUP BY customer_type
ORDER BY avg_spending DESC;


-- CUSTOMER PURCHASE BEHAVIOR

-- How many items do customers purchase on average per order?

-- Which customers purchase the highest number of items?

-- What is the average number of items purchased by one-time and repeat customers?

-- Which customers have the highest total number of purchased items?


-- CUSTOMER GEOGRAPHY

-- Which states have the highest number of customers?

-- Which states generate the highest total revenue?

-- Which states have the highest average customer spending?

-- Which cities have the highest number of customers?

-- Which cities generate the highest total revenue?


-- CUSTOMER VALUE OVER TIME

-- How does the number of new customers change over time?

-- How does customer revenue change over time?

-- How does the number of repeat customers change over time?

-- How does average customer spending change over time?


-- CUSTOMER PRODUCT PREFERENCES

-- Which product categories are most popular among customers?

-- Which product categories generate the most customer revenue?

-- Which product categories are purchased most frequently by repeat customers?


-- CUSTOMER BUSINESS INSIGHTS

-- What proportion of total revenue comes from the highest-spending customers?

-- How concentrated is revenue among customers?

-- Do customers with more orders also generate more total revenue?

-- Do repeat customers generate more revenue per customer than one-time customers?
