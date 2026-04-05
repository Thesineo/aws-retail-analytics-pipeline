-- KPI 6: Top 10 Customers by Spend
SELECT
  customerid,
  COUNT(DISTINCT invoiceno)                    AS total_orders,
  ROUND(SUM(CAST(revenue AS DOUBLE)), 2)       AS total_spent
FROM retail_db.retail_clean
WHERE CAST(quantity AS INT) > 0
  AND CAST(price AS DOUBLE) > 0
  AND customerid IS NOT NULL
GROUP BY customerid
ORDER BY total_spent DESC
LIMIT 10;
