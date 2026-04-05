# 🛒 UK Retail Analytics Pipeline
### End-to-End Cloud Analytics on AWS | 500,000+ Transactions

![Python](https://img.shields.io/badge/PySpark-ETL-orange?logo=apachespark)
![AWS](https://img.shields.io/badge/AWS-S3%20%7C%20Glue%20%7C%20Athena-FF9900?logo=amazonaws)
![SQL](https://img.shields.io/badge/SQL-Athena-blue)
![Dashboard](https://img.shields.io/badge/Dashboard-Looker%20Studio-green?logo=googleanalytics)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

> **End-to-end cloud analytics pipeline** | Raw CSV → S3 Data Lake → Glue ETL → Athena SQL → Live Dashboard

---

## 📌 Business Problem

A UK-based online retailer generates over 500,000 transactions across 38 countries but had no scalable way to analyse revenue performance, customer behaviour, or product trends. This project builds a **fully automated cloud analytics pipeline on AWS** that transforms raw transactional data into an interactive business intelligence dashboard — answering the key questions that drive investment decisions.

**Key business questions answered:**
- Which months generated the highest revenue and what drove the peaks?
- Which countries and products contribute the most value?
- Who are the top customers by lifetime spend?
- What is the average order value across the business?
- What percentage of customers are repeat buyers?

---

## 🔴 Live Dashboard

[View Interactive Dashboard](your-looker-studio-link-here)

---

## 🏗️ Architecture

```
UCI Online Retail II Dataset (500K+ rows)
              ↓  manual upload
    ┌─────────────────────┐
    │   Amazon S3         │  ← Data Lake
    │   /raw/             │     retail_raw.csv
    │   /processed/       │     retail_clean/ (Parquet)
    │   /athena-results/  │     query outputs
    └──────────┬──────────┘
               │
       ┌───────┴────────┐
       │                │
  AWS Glue ETL     Amazon Athena
  (PySpark)        (Serverless SQL)
       │                │
  Clean Parquet    6 KPI Queries
  Partitioned by   ↓
  year_month       CSV Downloads
                        │
               Looker Studio
               Interactive Dashboard
               6 Charts + Country Filter
```

Full architecture details: [architecture/pipeline_diagram.md](architecture/pipeline_diagram.md)

---

## 🛠️ Tech Stack

| Tool | Purpose |
|---|---|
| `Amazon S3` | Data lake — raw and processed storage |
| `AWS Glue (PySpark)` | ETL pipeline — clean, transform, partition |
| `Amazon Athena` | Serverless SQL engine on S3 |
| `Looker Studio` | Interactive BI dashboard |
| `Python` | Glue ETL scripting |
| `SQL` | KPI analytical query layer |
| `IAM` | Access management and security |

---

## 📦 Pipeline Stages

### Stage 1 — S3 Data Lake
Raw CSV uploaded to `s3://aniket-analytics-26/raw/`. Organised into three folders:
```
aniket-analytics-26/
  ├── raw/                ← original retail_raw.csv
  ├── processed/          ← Glue Parquet output, partitioned by year_month
  └── athena-results/     ← Athena query result storage
```

### Stage 2 — AWS Glue ETL (PySpark)
Managed PySpark job that performs the following transformations:
- Renames all columns to remove spaces (e.g. `Customer ID` → `customerid`)
- Parses mixed date formats (`M/d/yyyy` and `M/d/yy`) using LEGACY parser
- Filters out returns (negative quantity), null dates, and zero-price rows
- Calculates `revenue = quantity × price` for each line item
- Uppercases and trims country names for consistency
- Writes clean output as **Parquet**, partitioned by `year_month` for fast querying

Script: [glue/retail_etl_job.py](glue/retail_etl_job.py)

### Stage 3 — Amazon Athena
Serverless SQL engine querying Parquet directly from S3 — no database server required. Two tables created:

| Table | Source | Purpose |
|---|---|---|
| `retail_db.retail_raw` | S3 `/raw/` CSV | Raw data exploration |
| `retail_db.retail_clean` | S3 `/processed/` Parquet | KPI production queries |

Setup scripts: [sql/01_create_raw_table.sql](sql/01_create_raw_table.sql) | [sql/02_create_clean_table.sql](sql/02_create_clean_table.sql)

### Stage 4 — KPI SQL Layer
Six business-facing analytical queries built on `retail_db.retail_clean`:

| File | Business Question |
|---|---|
| [kpi1_monthly_revenue.sql](sql/kpi1_monthly_revenue.sql) | How does revenue trend month by month? |
| [kpi2_revenue_by_country.sql](sql/kpi2_revenue_by_country.sql) | Which countries generate the most revenue? |
| [kpi3_top_products.sql](sql/kpi3_top_products.sql) | What are the top 10 products by revenue? |
| [kpi4_summary_stats.sql](sql/kpi4_summary_stats.sql) | What are the headline KPI numbers? |
| [kpi5_country_share.sql](sql/kpi5_country_share.sql) | What is each country's revenue share? |
| [kpi6_top_customers.sql](sql/kpi6_top_customers.sql) | Who are the top 10 customers by spend? |

### Stage 5 — Looker Studio Dashboard
Interactive dashboard built from Athena query exports:
- 4 KPI scorecards — Total Revenue, Total Orders, Unique Customers, Avg Order Value
- Monthly Revenue Trend — bar chart showing full 13-month period
- Revenue by Country — horizontal bar, top 15 countries
- Top 10 Products by Revenue — horizontal bar with data labels
- Revenue Share by Country — donut chart, top 8 countries
- Top 10 Customers by Spend — table with inline bar visualisation
- Interactive country dropdown filter — filters all charts simultaneously

---

## 📊 Results

| KPI | Value |
|---|---|
| Total Revenue (GBP) | add your value |
| Total Orders | add your value |
| Unique Customers | add your value |
| Avg Order Value (GBP) | add your value |
| Top Revenue Country | United Kingdom |
| Top Product | add your value |
| Date Range | Dec 2010 – Dec 2011 |

---

## 🔬 Key Findings

- The UK accounts for the majority of total revenue — international markets represent a significant growth opportunity
- Revenue peaks in November 2011 driven by seasonal gift and homeware purchasing ahead of Christmas
- Top 10 products are all homeware and gift items — consistent with a seasonal UK retail profile
- High repeat customer rate indicates strong customer retention in the core UK market

---

## 📁 Repository Structure

```
aws-retail-analytics-pipeline/
├── README.md
├── sql/
│   ├── 01_create_raw_table.sql       ← Athena setup: raw CSV table
│   ├── 02_create_clean_table.sql     ← Athena setup: clean Parquet table
│   ├── kpi1_monthly_revenue.sql
│   ├── kpi2_revenue_by_country.sql
│   ├── kpi3_top_products.sql
│   ├── kpi4_summary_stats.sql
│   ├── kpi5_country_share.sql
│   └── kpi6_top_customers.sql
├── glue/
│   └── retail_etl_job.py             ← PySpark ETL script
├── architecture/
│   └── pipeline_diagram.md           ← full pipeline diagram
└── outputs/
    └── dashboard_screenshot.png      ← dashboard preview
```

---

## 🚀 How to Reproduce

```
1. Create an AWS account and S3 bucket
2. Upload retail_raw.csv to the /raw/ folder in S3
3. Create IAM role (GlueRetailRole) with S3 + Glue permissions
4. Run sql/01_create_raw_table.sql in Amazon Athena
5. Create Glue ETL job using glue/retail_etl_job.py → Run
6. Run sql/02_create_clean_table.sql in Athena
7. Run all 6 KPI queries → download each as CSV
8. Upload CSVs to Looker Studio → build dashboard
```

---

## 🔒 Security

- IAM role (GlueRetailRole) with least-privilege S3 and Glue permissions only
- S3 bucket with all public access blocked
- No AWS credentials or access keys stored in any code file
- Billing alert set at $5 to prevent unexpected charges

---

## 📂 Dataset

- Source: [UCI Online Retail II Dataset](https://archive.ics.uci.edu/dataset/502/online+retail+ii)
- Period: December 2010 – December 2011
- Records: 500,000+ transactions
- Countries: 38
- Original format: Excel (.xlsx) → converted to CSV for S3 upload

---

## 👤 Author

**Aniket Amar Nerali**
MSc Business Analytics and Decision Sciences — University of Leeds

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?logo=linkedin)](https://linkedin.com/in/your-profile)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black?logo=github)](https://github.com/Thesineo)
