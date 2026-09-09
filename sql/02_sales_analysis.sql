SET search_path TO olist;


-- SALES PERFORMANCE

-- What is the total product revenue generated?
SELECT SUM(price) AS total_product_revenue
FROM order_items;

-- How many orders were placed?
SELECT COUNT(*) AS total_orders
FROM orders;

-- How many items were sold?
SELECT COUNT(*) AS total_items_sold
FROM order_items;

-- What is the average order value?
SELECT AVG(order_value)
FROM (
    SELECT 
        order_id,
        SUM(price) AS order_value
    FROM order_items
    GROUP BY order_id
);

-- What is the average number of items per order?
SELECT AVG(items_per_order) AS average_items_per_order
FROM (
    SELECT
        order_id,
        COUNT(product_id) AS items_per_order
    FROM order_items
    GROUP BY order_id
);


-- SALES TRENDS

-- How does monthly revenue change over time?
SELECT
    TO_CHAR(DATE_TRUNC('month', o.order_purchase_timestamp), 'Mon YYYY') AS month,
    SUM(oi.price) AS monthly_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY DATE_TRUNC('month', o.order_purchase_timestamp);

-- How does the monthly number of orders change over time?
SELECT
    TO_CHAR(DATE_TRUNC('month', order_purchase_timestamp), 'Mon YYYY') AS month,
    COUNT(*) AS monthly_orders
FROM orders
GROUP BY DATE_TRUNC('month', order_purchase_timestamp)
ORDER BY DATE_TRUNC('month', order_purchase_timestamp);

-- Which month generated the highest revenue?
SELECT
    TO_CHAR(DATE_TRUNC('month', o.order_purchase_timestamp), 'Mon YYYY') AS month,
    SUM(oi.price) AS monthly_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY monthly_revenue DESC
LIMIT 1;

-- Which month had the highest number of orders?
SELECT
    TO_CHAR(DATE_TRUNC('month', order_purchase_timestamp), 'Mon YYYY') AS month,
    COUNT(*) AS monthly_orders
FROM orders
GROUP BY DATE_TRUNC('month', order_purchase_timestamp)
ORDER BY monthly_orders DESC
LIMIT 1;


-- PAYMENT ANALYSIS

-- Which payment methods are used most frequently?
SELECT
    payment_type,
    COUNT(*) AS payment_count
FROM order_payments
GROUP BY payment_type
ORDER BY payment_count DESC;

-- Which payment methods account for the largest share of total payment value?
SELECT
    payment_type,
    SUM(payment_value) AS total_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;

-- What is the average payment value for each payment method?
SELECT
    payment_type,
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY average_payment_value DESC;

-- How many installments are typically used for credit card payments?
SELECT ROUND(AVG(payment_installments), 2) AS average_installments
FROM order_payments
WHERE payment_type = 'credit_card';


-- ORDER STATUS

-- What is the distribution of orders across each order status?
SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- What percentage of orders were successfully delivered?
SELECT ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders) ,2) AS delivered_order_percentage
FROM orders
WHERE order_status = 'delivered';

-- How many orders were canceled?
SELECT
    COUNT(*) AS canceled_orders
FROM orders
WHERE order_status = 'canceled';


-- ORDER TIMING

-- Which day of the week has the highest number of orders?
SELECT
	TO_CHAR(order_purchase_timestamp, 'Day') AS idk,
    COUNT(*) AS idk2
FROM orders
GROUP BY idk
ORDER BY idk2 DESC
LIMIT 1;

-- Which hour of the day has the highest number of orders?
SELECT
    TO_CHAR(order_purchase_timestamp, 'HH24') AS order_hour,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_hour
ORDER BY order_count DESC
LIMIT 1;


-- GEOGRAPHIC SALES PERFORMANCE

-- Which customer states generate the most revenue?
SELECT
    c.customer_state,
    SUM(oi.price) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

-- Which customer states have the highest number of orders?
SELECT
    c.customer_state,
    COUNT(*) AS order_count
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY order_count DESC;

-- Which customer states have the highest average order value?

SELECT
    c.customer_state,
    AVG(order_value) AS average_order_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN (
    SELECT
        order_id,
        SUM(price) AS order_value
    FROM order_items
    GROUP BY order_id
) oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY average_order_value DESC;
