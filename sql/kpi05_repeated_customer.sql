SELECT                                                                                                                                
  COUNT(DISTINCT customerid)                       AS total_customers,
  COUNT(DISTINCT CASE
    WHEN order_count > 1 THEN customerid END)      AS repeat_customers,
  ROUND(100.0 * COUNT(DISTINCT CASE
    WHEN order_count > 1 THEN customerid END)
    / NULLIF(COUNT(DISTINCT customerid), 0), 1)    AS repeat_pct
FROM (
  SELECT
    customerid,
    COUNT(DISTINCT invoiceno) AS order_count
  FROM retail_db.retail_clean
  WHERE customerid IS NOT NULL
    AND customerid != ''
  GROUP BY customerid
);                                                                                                                                    
