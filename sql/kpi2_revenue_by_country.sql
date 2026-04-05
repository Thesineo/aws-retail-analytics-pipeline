-- KPI 2: Revenue by Country
SELECT
  country,
  ROUND(SUM(CAST(revenue AS DOUBLE)), 2)     AS total_revenue,
  COUNT(DISTINCT invoiceno)                   AS total_orders,
  COUNT(DISTINCT customerid)                  AS unique_customers
FROM retail_db.retail_clean
WHERE CAST(quantity AS INT) > 0
  AND CAST(price AS DOUBLE) > 0
  AND country IS NOT NULL
GROUP BY country
ORDER BY total_revenue DESC
LIMIT 15;
