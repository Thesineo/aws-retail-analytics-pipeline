-- KPI 1: Monthly Revenue Trend
SELECT
  CONCAT(
    CASE SUBSTR(year_month, 6, 2)
      WHEN '01' THEN 'Jan' WHEN '02' THEN 'Feb'
      WHEN '03' THEN 'Mar' WHEN '04' THEN 'Apr'
      WHEN '05' THEN 'May' WHEN '06' THEN 'Jun'
      WHEN '07' THEN 'Jul' WHEN '08' THEN 'Aug'
      WHEN '09' THEN 'Sep' WHEN '10' THEN 'Oct'
      WHEN '11' THEN 'Nov' WHEN '12' THEN 'Dec'
    END,
    ' 20', SUBSTR(year_month, 3, 2)
  )                                          AS month_label,
  SUBSTR(year_month, 3, 2)                   AS sort_year,
  SUBSTR(year_month, 6, 2)                   AS sort_month,
  ROUND(SUM(CAST(revenue AS DOUBLE)), 2)     AS monthly_revenue,
  COUNT(DISTINCT invoiceno)                  AS total_orders
FROM retail_db.retail_clean
WHERE CAST(quantity AS INT) > 0
  AND CAST(price AS DOUBLE) > 0
  AND year_month IS NOT NULL
GROUP BY 1, 2, 3
ORDER BY sort_year, sort_month;
