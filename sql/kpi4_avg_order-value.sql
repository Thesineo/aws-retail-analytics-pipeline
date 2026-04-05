-- KPI 4 : Avg Order Value
SELECT 
   ROUND(
      SUM(revenue) / NULLIF(COUNT(DISTINCT invoiceno),0)
      , 2) AS avg_order_value
FROM retail_db.retail_clean
WHERE quantity > 0 
  AND price > 0;
