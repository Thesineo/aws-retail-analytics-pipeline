-- ============================================
-- Step 1: Create database
-- Run in: AWS Athena
-- ============================================
CREATE DATABASE IF NOT EXISTS retail_db;

-- ============================================
-- Step 2: Create external table on raw CSV
-- Location: S3 raw folder
-- ============================================
CREATE EXTERNAL TABLE IF NOT EXISTS retail_db.retail_raw (
  invoiceno   STRING,
  stockcode   STRING,
  description STRING,
  quantity    INT,
  invoicedate STRING,
  price       DOUBLE,
  customerid  STRING,
  country     STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar'     = '"',
  'escapeChar'    = '\\'
)
STORED AS TEXTFILE
LOCATION 's3://aniket-analytics-26/raw/'
TBLPROPERTIES ('skip.header.line.count'='1');

-- ============================================
-- Step 3: Verify
-- ============================================
SELECT * FROM retail_db.retail_raw LIMIT 5;
