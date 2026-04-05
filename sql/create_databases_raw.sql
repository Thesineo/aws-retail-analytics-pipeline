CREATE DATABASE retail_db;

-- Create a table pointing at your S3 CSV
CREATE EXTERNAL TABLE retail_db.retail_raw (
  InvoiceNo   STRING,
  StockCode   STRING,
  Description STRING,
  Quantity    INT,
  InvoiceDate STRING,
  Price       DOUBLE,
  CustomerID  STRING,
  Country     STRING
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

SHOW DATABASES;
