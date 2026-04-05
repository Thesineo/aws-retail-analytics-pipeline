-- KPI 3: Top 10 Products by Revenue
SELECT
  description,
  SUM(CAST(quantity AS INT))                  AS units_sold,
  ROUND(SUM(CAST(revenue AS DOUBLE)), 2)      AS revenue
FROM retail_db.retail_clean
WHERE CAST(quantity AS INT) > 0
  AND CAST(price AS DOUBLE) > 0
  AND description IS NOT NULL
GROUP BY description
ORDER BY revenue DESC
LIMIT 10;
