# Pipeline Architecture — UK Retail Analytics

## End-to-End Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         DATA SOURCE                             │
│            UCI Online Retail II Dataset                         │
│        500,000+ transactions | UK 2010–2011 | 38 countries      │
│              Excel (.xlsx) → converted to CSV                   │
└──────────────────────────┬──────────────────────────────────────┘
                           │ Manual upload
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                   AMAZON S3 — DATA LAKE                         │
│                   aniket-analytics-26                           │
│                                                                 │
│  /raw/                /processed/            /athena-results/   │
│  retail_raw.csv  →    retail_clean/      →   query outputs      │
│  (original CSV)       (Parquet files,        (Athena saves      │
│                        partitioned by         results here)     │
│                        year_month)                              │
└──────────┬────────────────────┬────────────────────────────────-┘
           │                    │
     AWS Glue ETL         Amazon Athena
     (PySpark)            (Serverless SQL)
           │                    │
           ▼                    ▼
┌──────────────────┐  ┌───────────────────────────────────────────┐
│   AWS GLUE JOB   │  │           AMAZON ATHENA                   │
│                  │  │                                           │
│ 1. Read raw CSV  │  │  Database:  retail_db                     │
│ 2. Rename cols   │  │                                           │
│    (remove       │  │  Tables:                                  │
│     spaces)      │  │  · retail_raw   → raw CSV                 │
│ 3. Cast types    │  │  · retail_clean → clean Parquet           │
│    (int, double) │  │                                           │
│ 4. Parse dates   │  │  6 KPI Queries:                           │
│    (LEGACY mode) │  │  · kpi1 monthly revenue trend             │
│ 5. Filter rows   │  │  · kpi2 revenue by country                │
│    (qty>0,       │  │  · kpi3 top 10 products                   │
│     price>0,     │  │  · kpi4 summary stats (4 KPIs)            │
│     date!=null)  │  │  · kpi5 country revenue share             │
│ 6. Add revenue   │  │  · kpi6 top 10 customers                  │
│    col           │  │                                           │
│ 7. Write Parquet │  └────────────────────┬──────────────────────┘
│    partition by  │                       │ CSV download
│    year_month    │                       │ (6 files)
└──────────────────┘                       ▼
                            ┌──────────────────────────────────────┐
                            │       LOOKER STUDIO DASHBOARD        │
                            │                                      │
                            │  KPI Scorecards (row 1):             │
                            │  · Total Revenue                     │
                            │  · Total Orders                      │
                            │  · Unique Customers                  │
                            │  · Avg Order Value                   │
                            │                                      │
                            │  Charts (rows 2-3):                  │
                            │  · Monthly Revenue Trend (bar)       │
                            │  · Revenue by Country (horiz. bar)   │
                            │  · Top 10 Products (horiz. bar)      │
                            │  · Revenue Share (donut chart)       │
                            │  · Top 10 Customers (table)          │
                            │                                      │
                            │  Interactivity:                      │
                            │  · Country dropdown filter           │
                            │    (filters all charts at once)      │
                            └──────────────────────────────────────┘
```

---

## AWS Services Summary

| Service | Role | Cost (free tier) |
|---|---|---|
| Amazon S3 | Data lake storage | 5GB free |
| AWS Glue | Managed PySpark ETL | 10 DPU-hours/month free |
| Amazon Athena | Serverless SQL on S3 | $5 per TB scanned |
| IAM | Access management | Always free |

---

## IAM Security Model

```
Root Account
    └── aniket-admin (IAM user — daily use)
            └── AdministratorAccess policy

GlueRetailRole (service role for Glue)
    ├── AmazonS3FullAccess
    └── AWSGlueServiceRole
```

---

## S3 Folder Structure

```
aniket-analytics-26/
    ├── raw/
    │   └── retail_raw.csv              ← source data (50MB)
    ├── processed/
    │   └── retail_clean/
    │       ├── year_month=2010-12/     ← Parquet partition
    │       ├── year_month=2011-01/
    │       ├── year_month=2011-02/
    │       └── ...
    └── athena-results/                 ← Athena saves query CSVs here
```

---

## Data Transformation Summary

| Step | Input | Output | Tool |
|---|---|---|---|
| Raw ingestion | Excel → CSV | retail_raw.csv in S3 | Manual |
| Schema registration | CSV in S3 | retail_raw Athena table | Athena DDL |
| ETL cleaning | retail_raw.csv | retail_clean/ Parquet | AWS Glue |
| Table registration | Parquet in S3 | retail_clean Athena table | Athena DDL |
| KPI analysis | retail_clean table | 6 CSV result files | Athena SQL |
| Visualisation | 6 CSV files | Interactive dashboard | Looker Studio |
