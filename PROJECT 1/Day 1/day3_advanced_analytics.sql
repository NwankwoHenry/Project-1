-- Calculates RFM scores and segments for every customer, including customers with no purchases.
WITH sales_summary AS (
	SELECT TRY_CONVERT(int, s.customer_id) AS cust_id,
		   DATEDIFF(day, MAX(s.date), MAX(MAX(s.date)) OVER ()) AS recency_days,
		   COUNT(DISTINCT s.date) AS frequency,
		   SUM(s.quantity * s.unit_price * (1 - s.discount_pct / 100.0)) AS monetary
	FROM dbo.bm_sales AS s
	WHERE s.customer_id IS NOT NULL
	GROUP BY TRY_CONVERT(int, s.customer_id)
), rfm_quintiles AS (
	SELECT cust_id,
		   recency_days,
		   frequency,
		   monetary,
		   6 - NTILE(5) OVER (ORDER BY recency_days) AS recency_score,
		   NTILE(5) OVER (ORDER BY frequency) AS frequency_score,
		   NTILE(5) OVER (ORDER BY monetary) AS monetary_score
	FROM sales_summary
), customer_rfm AS (
	SELECT c.cust_id,
		   COALESCE(r.recency_days, 0) AS recency_days,
		   COALESCE(r.frequency, 0) AS frequency,
		   COALESCE(r.monetary, 0) AS monetary,
		   COALESCE(r.recency_score, 0) AS recency_score,
		   COALESCE(r.frequency_score, 0) AS frequency_score,
		   COALESCE(r.monetary_score, 0) AS monetary_score
	FROM dbo.bm_customers AS c
	LEFT JOIN rfm_quintiles AS r ON r.cust_id = c.cust_id
)
SELECT cust_id,
	   recency_days,
	   frequency,
	   monetary,
	   recency_score,
	   frequency_score,
	   monetary_score,
	   CASE
		   WHEN frequency = 0 THEN 'Lost'
		   WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
		   WHEN frequency_score >= 4 THEN 'Loyal'
		   WHEN recency_score <= 2 AND monetary_score >= 4 THEN 'At Risk'
		   WHEN recency_score <= 2 AND frequency_score <= 2 THEN 'Lost'
		   ELSE 'Others'
	   END AS segment
FROM customer_rfm
ORDER BY cust_id;


-- Calculates monthly cohort retention for customers who registered in each calendar month.
WITH customer_cohorts AS (
	SELECT cust_id,
		   DATEFROMPARTS(YEAR(registration_date), MONTH(registration_date), 1) AS cohort_month
	FROM dbo.bm_customers
), cohort_sizes AS (
	SELECT cohort_month,
		   COUNT(*) AS cohort_customers
	FROM customer_cohorts
	GROUP BY cohort_month
), months_since_signup AS (
	SELECT month_number
	FROM (VALUES (0), (1), (2), (3), (4), (5), (6)) AS months(month_number)
), customer_activity AS (
	SELECT DISTINCT TRY_CONVERT(int, s.customer_id) AS cust_id,
			   DATEFROMPARTS(YEAR(s.date), MONTH(s.date), 1) AS activity_month
	FROM dbo.bm_sales AS s
	WHERE s.customer_id IS NOT NULL
), cohort_activity AS (
	SELECT cc.cohort_month,
		   DATEDIFF(MONTH, cc.cohort_month, ca.activity_month) AS months_since_signup,
		   COUNT(DISTINCT ca.cust_id) AS active_customers
	FROM customer_cohorts AS cc
	INNER JOIN customer_activity AS ca ON ca.cust_id = cc.cust_id
	WHERE DATEDIFF(MONTH, cc.cohort_month, ca.activity_month) BETWEEN 0 AND 6
	GROUP BY cc.cohort_month, DATEDIFF(MONTH, cc.cohort_month, ca.activity_month)
)
SELECT cs.cohort_month,
	   m.month_number AS months_since_signup,
	   COALESCE(ca.active_customers, 0) AS active_customers,
	   CAST(100.0 * COALESCE(ca.active_customers, 0) / NULLIF(cs.cohort_customers, 0) AS DECIMAL(10, 2)) AS retention_pct
FROM cohort_sizes AS cs
CROSS JOIN months_since_signup AS m
LEFT JOIN cohort_activity AS ca
	ON ca.cohort_month = cs.cohort_month
	AND ca.months_since_signup = m.month_number
ORDER BY cs.cohort_month, m.month_number;


-- Finds the 15 most frequently co-purchased product pairs using customer-date baskets.
SELECT TOP 15
	   s1.sku_id AS sku_id_1,
	   sk1.sku_name AS sku_name_1,
	   s2.sku_id AS sku_id_2,
	   sk2.sku_name AS sku_name_2,
	   COUNT(*) AS pair_count
FROM dbo.bm_sales AS s1
INNER JOIN dbo.bm_sales AS s2
	ON s1.customer_id = s2.customer_id
	AND s1.date = s2.date
	AND s1.sku_id < s2.sku_id
INNER JOIN dbo.bm_skus AS sk1 ON sk1.sku_id = s1.sku_id
INNER JOIN dbo.bm_skus AS sk2 ON sk2.sku_id = s2.sku_id
GROUP BY s1.sku_id, sk1.sku_name, s2.sku_id, sk2.sku_name
ORDER BY pair_count DESC;


-- Calculates annual discounted revenue, previous-year revenue, and year-over-year percentage change.
WITH yearly_revenue AS (
	SELECT YEAR(s.date) AS sales_year,
		   SUM(s.quantity * s.unit_price * (1 - s.discount_pct / 100.0)) AS total_revenue
	FROM dbo.bm_sales AS s
	GROUP BY YEAR(s.date)
), revenue_with_previous_year AS (
	SELECT sales_year,
		   total_revenue,
		   LAG(total_revenue) OVER (ORDER BY sales_year) AS previous_year_revenue
	FROM yearly_revenue
)
SELECT sales_year,
	   total_revenue,
	   previous_year_revenue,
	   100.0 * (total_revenue - previous_year_revenue) / NULLIF(previous_year_revenue, 0) AS year_over_year_pct_change
FROM revenue_with_previous_year
ORDER BY sales_year;

-- Calculates monthly discounted revenue and the cumulative running revenue total in chronological order.
WITH monthly_revenue AS (
	SELECT YEAR(s.date) AS sales_year,
		   MONTH(s.date) AS sales_month,
		   SUM(s.quantity * s.unit_price * (1 - s.discount_pct / 100.0)) AS total_revenue
	FROM dbo.bm_sales AS s
	GROUP BY YEAR(s.date), MONTH(s.date)
)
SELECT sales_year,
	   sales_month,
	   total_revenue,
	   SUM(total_revenue) OVER (
		   ORDER BY sales_year, sales_month
		   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	   ) AS running_total_revenue
FROM monthly_revenue
ORDER BY sales_year, sales_month;

