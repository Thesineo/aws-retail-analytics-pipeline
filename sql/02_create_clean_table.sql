-- ============================================
-- Create external table on Glue processed data
-- Prerequisite: Run Glue ETL job first
-- Location: S3 processed/retail_clean/ folder
-- Format: Parquet, partitioned by year_month
-- ============================================
DROP TABLE IF EXISTS retail_db.retail_clean;

CREATE EXTERNAL TABLE retail_db.retail_clean (
  invoiceno   STRING,
  stockcode   STRING,
  description STRING,
  quantity    INT,
  invoicedate TIMESTAMP,
  price       DOUBLE,
  customerid  STRING,
  country     STRING,
  revenue     DOUBLE
)
PARTITIONED BY (year_month STRING)
STORED AS PARQUET
LOCATION 's3://aniket-analytics-26/processed/retail_clean/';

-- Load all partitions automatically
MSCK REPAIR TABLE retail_db.retail_clean;

-- ============================================
-- Verify data loaded correctly
-- ============================================
SELECT
  year_month,
  COUNT(*)                               AS row_count,
  ROUND(SUM(revenue), 2)                 AS monthly_revenue
FROM retail_db.retail_clean
GROUP BY year_month
ORDER BY year_month
LIMIT 5;
