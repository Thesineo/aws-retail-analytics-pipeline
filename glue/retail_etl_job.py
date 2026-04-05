import sys
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import (
    col, round as spark_round,
    date_format, upper, trim, to_timestamp, coalesce
)

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

spark.conf.set("spark.sql.legacy.timeParserPolicy", "LEGACY")
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInWrite", "LEGACY")

# 1. Read raw CSV
df = spark.read \
    .option("header", True) \
    .option("inferSchema", False) \
    .csv("s3://aniket-analytics-26/raw/retail_raw.csv")

print(f"Raw columns: {df.columns}")
print(f"Raw row count: {df.count()}")

# 2. Rename all columns cleanly
df = df.withColumnRenamed("Invoice",      "invoiceno") \
       .withColumnRenamed("StockCode",    "stockcode") \
       .withColumnRenamed("Description",  "description") \
       .withColumnRenamed("Quantity",     "quantity") \
       .withColumnRenamed("Invoice Date", "invoicedate") \
       .withColumnRenamed("Price",        "price") \
       .withColumnRenamed("Customer ID",  "customerid") \
       .withColumnRenamed("Country",      "country")

print(f"Renamed columns: {df.columns}")

# 3. Cast numeric columns
df = df.withColumn("quantity", col("quantity").cast("integer")) \
       .withColumn("price",    col("price").cast("double"))

# 4. Parse dates
df = df.withColumn("invoicedate",
    coalesce(
        to_timestamp(col("invoicedate"), "M/d/yyyy H:mm"),
        to_timestamp(col("invoicedate"), "M/d/yy H:mm"),
        to_timestamp(col("invoicedate"), "yyyy-MM-dd HH:mm:ss")
    )
)

# 5. Clean and add revenue
df_clean = df \
    .filter(col("quantity") > 0) \
    .filter(col("price") > 0) \
    .filter(col("invoicedate").isNotNull()) \
    .withColumn("revenue",
        spark_round(col("quantity") * col("price"), 2)) \
    .withColumn("country", upper(trim(col("country"))))

# 6. Add year_month partition
df_clean = df_clean.withColumn(
    "year_month", date_format(col("invoicedate"), "yyyy-MM")
)

print(f"Clean row count: {df_clean.count()}")
df_clean.show(3, truncate=False)

# 7. Write parquet
df_clean.write \
    .mode("overwrite") \
    .partitionBy("year_month") \
    .parquet("s3://aniket-analytics-26/processed/retail_clean/")

print("Done!")
job.commit()
