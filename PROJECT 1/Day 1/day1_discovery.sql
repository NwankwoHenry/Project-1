-- Returns the row count for each of the six database tables in one result set.
SELECT 'bm_customers' AS table_name, COUNT(*) AS row_count FROM bm_customers
UNION ALL
SELECT 'bm_stores', COUNT(*) FROM bm_stores
UNION ALL
SELECT 'bm_skus', COUNT(*) FROM bm_skus
UNION ALL
SELECT 'bm_sales', COUNT(*) FROM bm_sales
UNION ALL
SELECT 'bm_promotions', COUNT(*) FROM bm_promotions
UNION ALL
SELECT 'bm_inventory', COUNT(*) FROM bm_inventory;

-- Counts NULL values in every column of bm_sales, with one row of output.
SELECT
	SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS date_null_count,
	SUM(CASE WHEN store_id IS NULL THEN 1 ELSE 0 END) AS store_id_null_count,
	SUM(CASE WHEN sku_id IS NULL THEN 1 ELSE 0 END) AS sku_id_null_count,
	SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_null_count,
	SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS quantity_null_count,
	SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS unit_price_null_count,
	SUM(CASE WHEN total_value IS NULL THEN 1 ELSE 0 END) AS total_value_null_count,
	SUM(CASE WHEN channel IS NULL THEN 1 ELSE 0 END) AS channel_null_count,
	SUM(CASE WHEN discount_pct IS NULL THEN 1 ELSE 0 END) AS discount_pct_null_count
FROM bm_sales;

-- Counts NULL values in every column of bm_customers, with one row of output.
SELECT
	SUM(CASE WHEN cust_id IS NULL THEN 1 ELSE 0 END) AS cust_id_null_count,
	SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS age_null_count,
	SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS gender_null_count,
	SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS city_null_count,
	SUM(CASE WHEN loyalty_segment IS NULL THEN 1 ELSE 0 END) AS loyalty_segment_null_count,
	SUM(CASE WHEN preferred_channel IS NULL THEN 1 ELSE 0 END) AS preferred_channel_null_count,
	SUM(CASE WHEN registration_date IS NULL THEN 1 ELSE 0 END) AS registration_date_null_count
FROM bm_customers;

-- Selects all sales made through the Store channel.
SELECT *
FROM bm_sales
WHERE channel = 'Store';

-- Selects all customers in the Gold loyalty segment.
SELECT *
FROM bm_customers
WHERE loyalty_segment = 'Gold';

-- Selects all SKUs in the Electronics category.
SELECT *
FROM bm_skus
WHERE category = 'Electronics';

-- Shows each sale's date and quantity with the SKU name and category.
SELECT s.date, s.quantity, k.sku_name, k.category
FROM bm_sales AS s
INNER JOIN bm_skus AS k ON s.sku_id = k.sku_id;

-- Shows each sale's date and total value with the store name and city.
SELECT s.date, s.total_value, t.store_name, t.city
FROM bm_sales AS s
INNER JOIN bm_stores AS t ON s.store_id = t.store_id;

-- Shows each sale's total value with the customer's loyalty segment and city.
SELECT s.total_value, c.loyalty_segment, c.city
FROM bm_sales AS s
INNER JOIN bm_customers AS c ON s.customer_id = c.cust_id;

-- Shows each sale's date, product category, store city, and total value.
SELECT s.date, k.category, t.city, s.total_value
FROM bm_sales AS s
INNER JOIN bm_skus AS k ON s.sku_id = k.sku_id
INNER JOIN bm_stores AS t ON s.store_id = t.store_id;

-- Shows each sale's loyalty segment, product category, and total value.
SELECT c.loyalty_segment, k.category, s.total_value
FROM bm_sales AS s
INNER JOIN bm_customers AS c ON s.customer_id = c.cust_id
INNER JOIN bm_skus AS k ON s.sku_id = k.sku_id;

-- Calculates total revenue grouped by store type and product category.
SELECT t.store_type, k.category, SUM(s.total_value) AS total_revenue
FROM bm_sales AS s
INNER JOIN bm_stores AS t ON s.store_id = t.store_id
INNER JOIN bm_skus AS k ON s.sku_id = k.sku_id
GROUP BY t.store_type, k.category;

-- Finds customers who have never made a purchase.
SELECT c.*
FROM bm_customers AS c
LEFT JOIN bm_sales AS s ON c.cust_id = s.customer_id
WHERE s.customer_id IS NULL;

-- Finds products that have never been sold.
SELECT k.*
FROM bm_skus AS k
LEFT JOIN bm_sales AS s ON k.sku_id = s.sku_id
WHERE s.sku_id IS NULL;

-- Finds stores with no inventory records.
SELECT t.*
FROM bm_stores AS t
LEFT JOIN bm_inventory AS i ON t.store_id = i.store_id
WHERE i.store_id IS NULL;

-- Returns the 10 highest-value transactions.
SELECT TOP 10*
FROM bm_sales
ORDER BY total_value DESC

-- Returns the five product categories with the highest total revenue.
SELECT TOP 5 k.category, SUM(s.total_value) AS total_revenue
FROM bm_sales AS s
INNER JOIN bm_skus AS k ON s.sku_id = k.sku_id
GROUP BY k.category
ORDER BY total_revenue DESC

-- Returns the five customers with the highest total spend.
SELECT TOP 5 c.cust_id, SUM(s.total_value) AS total_spend
FROM bm_sales AS s
INNER JOIN bm_customers AS c ON s.customer_id = c.cust_id
GROUP BY c.cust_id
ORDER BY total_spend DESC



