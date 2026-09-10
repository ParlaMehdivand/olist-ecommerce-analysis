SET search_path TO olist;


-- DATASET OVERVIEW

-- How many customers?
SELECT COUNT(*) AS total_customers
FROM customers;

-- How many orders?
SELECT COUNT(*) AS total_orders
FROM orders;

-- How many products?
SELECT COUNT(*) AS total_products
FROM products;

-- How many sellers?
SELECT COUNT(*) AS total_sellers
FROM sellers;


-- MISSING KEY IDENTIFIERS

-- How many customers have a missing customer_id?
SELECT COUNT(*) AS total_missing_customer_ids
FROM customers
WHERE customer_id IS NULL;

-- How many orders have a missing order_id?
SELECT COUNT(*) AS total_missing_order_ids
FROM orders
WHERE order_id IS NULL;

-- How many products have a missing product_id?
SELECT COUNT(*) AS total_missing_product_ids
FROM products
WHERE product_id IS NULL;

-- How many sellers have a missing seller_id?
SELECT COUNT(*) AS total_missing_seller_ids
FROM sellers
WHERE seller_id IS NULL;


-- DUPLICATE KEY IDENTIFIERS

-- Which customer_ids appear more than once?
SELECT
    customer_id,
    COUNT(*) AS duplicate_customer_id_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Which order_ids appear more than once?
SELECT 
    order_id,
    COUNT(*) AS duplicate_order_id_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Which product_ids appear more than once?
SELECT 
    product_id,
    COUNT(*) AS duplicate_product_id_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Which seller_ids appear more than once?
SELECT
    seller_id,
    COUNT(*) AS duplicate_seller_id_count
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;


-- MISSING IMPORTANT ATTRIBUTES

-- How many customers have a missing customer_city?
SELECT COUNT(*) AS total_missing_customer_cities
FROM customers
WHERE customer_city IS NULL;

-- How many customers have a missing customer_state?
SELECT COUNT(*) AS total_missing_customer_states
FROM customers
WHERE customer_state IS NULL;

-- How many products have a missing product_category_name?
SELECT COUNT(*) AS total_missing_product_category_names
FROM products
WHERE product_category_name IS NULL;

-- How many sellers have a missing seller_city?
SELECT COUNT(*) AS total_missing_seller_cities
FROM sellers
WHERE seller_city IS NULL;

-- How many sellers have a missing seller_state?
SELECT COUNT(*) AS total_missing_seller_states
FROM sellers
WHERE seller_state IS NULL;


-- INVALID / UNEXPECTED VALUES

-- Which order_status values are unexpected?
SELECT
    order_status,
    COUNT(*) AS unexpected_status_count
FROM orders
WHERE order_status NOT IN (
    'delivered',
    'shipped',
    'canceled',
    'invoiced',
    'processing',
    'approved',
    'unavailable',
    'created'
)
GROUP BY order_status;

-- Which payment_type values are unexpected?
SELECT
    payment_type,
    COUNT(*) AS unexpected_payment_type_count
FROM order_payments
WHERE payment_type NOT IN (
    'credit_card',
    'boleto',
    'voucher',
    'debit_card'
)
GROUP BY payment_type;

-- Which review_score values are invalid?
SELECT
    review_score,
    COUNT(*) AS invalid_review_score_count
FROM order_reviews
WHERE review_score NOT BETWEEN 1 AND 5
GROUP BY review_score;


-- DATE CONSISTENCY

-- Are there orders with an approval date earlier than the purchase date?
SELECT
    order_id,
    order_purchase_timestamp,
    order_approved_at
FROM orders
WHERE order_approved_at < order_purchase_timestamp;

-- Are there orders with a delivery date earlier than the purchase date?
SELECT
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date
FROM orders
WHERE order_delivered_customer_date < order_purchase_timestamp;

-- Are there orders delivered later than the estimated delivery date?
SELECT 
    order_id,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM orders
WHERE order_delivered_customer_date > order_estimated_delivery_date;


-- NUMERIC DATA VALIDATION

-- Are there order_items with a price less than or equal to zero?
SELECT 
    order_id,
    product_id,
    price
FROM order_items
WHERE price <= 0;

-- Are there order_items with a freight_value less than zero?
SELECT 
    order_id,
    product_id,
    freight_value
FROM order_items
WHERE freight_value < 0;

-- Are there products with zero or negative weight?
SELECT 
    product_id,
    product_weight_g
FROM products
WHERE product_weight_g <= 0;


-- REFERENTIAL INTEGRITY

-- Are there order_items referencing products that don't exist?
SELECT 
    oi.order_id,
    oi.product_id
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Are there order_items referencing sellers that don't exist?
SELECT
    oi.order_id,
    oi.seller_id
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- Are there orders referencing customers that don't exist?
SELECT 
    o.order_id,
    o.customer_id
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;