# Delta Air Lines - Customer Experience & Competitive Intelligence

---

## TL;DR

Delta Air Lines reviews (2017–2026) reveal a mid-tier performer in a low-satisfaction industry — avg rating **2.6/5**, only **33% of passengers would recommend**, with Wi-Fi and Ground Service as the most consistent underperformers. Despite low absolute scores, **year-over-year trends are positive across all KPIs**, and frequent flyers show significantly higher tolerance. Solo Leisure travellers in Economy Class represent the most dissatisfied and highest-volume segment.

<img width="849" height="582" alt="image" src="https://github.com/user-attachments/assets/cac7ce7f-df1d-46f2-bb56-6254def69459" />

- Access the dashboard 👉
- Access executive summary 👉 

---

## Summary

Analyzed **160,000+ airline reviews** from AirlineQuality.com (2017–2026) using SQL (Snowflake) and Mode Analytics to benchmark Delta Air Lines against its top competitors and surface actionable drivers of customer dissatisfaction.

Key insights: 
- Delta ranks **5th of 10** among the most-reviewed airlines globally with an average rating of 2.6/5 and a recommendation rate of 33%.
- The weakest service dimensions are **Wi-Fi & Connectivity** and **Ground Service**; relatively stronger is **Cabin Staff**, which is the only dimension that consistently outperforms the rest.
- Segment deep-dives (seat type, traveller type, layover status, flyer frequency) confirm that **Economy Class Solo Leisure passengers** are the primary driver of bad reviews, while frequent flyers (10+ flights) generate bad reviews at one-third the rate of first-time passengers.

Recommendation: 

| # | Action | Why |
|---|---|---|
| 🔴 1 | Upgrade WiFi infrastructure | 9-year chronic underperformer, critical for Solo Leisure |
| 🔴 2 | First-flight experience programme | 0.509 bad review rate — highest risk moment |
| 🟡 3 | Economy Class service standards | 82.8% of bad review volume lives here |
| 🟢 4 | Protect Cabin Staff quality | Only consistent strength across 9 years |

---

## 1. Overview

- **Scope:** 160,000+ Skytrax reviews from AirlineQuality.com filtered to verified reviews, with a Delta-focused lens and competitive benchmarking across airlines with ≥ 200 reviews.
- **Time Range:** 2017 – Q1 2026
- **Goal:** Identify key drivers of customer satisfaction and dissatisfaction for Delta Air Lines, benchmark performance against top competitors, and convert findings into targeted recommendations for the customer experience stakeholder.
- **Method:**
  - **SQL (Snowflake)** — data extraction, joins across fact and dimension tables (FCT_REVIEW, DIM_AIRLINE, DIM_CUSTOMER, DIM_DATE, DIM_LOCATION, DIM_AIRCRAFT), metric calculation, and confounding variable analysis
  - **Mode Analytics** — interactive dashboard, all primary visualisations, KPI cards, choropleth map, competitor benchmarking charts
- **Data Model:** Star schema — FCT_REVIEW as the central fact table joined to DIM_AIRLINE, DIM_CUSTOMER, DIM_DATE (date flown), DIM_LOCATION (origin, destination, transit), DIM_AIRCRAFT

---

## 2. Architecture

```text
                    ┌──────────────────────────────┐
                    │   airlinequality.com         │
                    └──────────────┬───────────────┘
                                   │ scrape (26 A-Z tasks)
                                   ▼
                    ┌──────────────────────────────┐
                    │   S3: raw/YYYY/MM/           │
                    │   raw_data_YYYYMMDD.csv      │
                    └──────────────┬───────────────┘
                                   │ clean + transform
                                   ▼
                    ┌──────────────────────────────┐
                    │   S3: processed/YYYY/MM/     │
                    │   clean_data_YYYYMMDD.csv    │
                    └──────────────┬───────────────┘
                                   │ COPY INTO
                                   ▼
                    ┌──────────────────────────────┐
                    │   Snowflake                  │
                    │   SKYTRAX_REVIEWS_DB.RAW     │
                    │   .AIRLINE_REVIEWS           │
                    └──────────────────────────────┘
                                   │ Dashboarding with
                                   ▼
                    ┌──────────────────────────────┐
                    │   Mode (analytics platform)  │
                    └──────────────────────────────┘

```

## 3. Tech Stack

| Layer | Technology |
| ----- | ---------- |
| Orchestrator | Apache Airflow (Astronomer Runtime, Docker) |
| Storage | AWS S3 (landing zone) → Snowflake |
| IaC | Terraform (AWS + Snowflake) |
| Language | Python 3.12, pandas, BeautifulSoup |

### S3 Bucket Structure

Data is date-partitioned by review date, organized into two prefixes:

```text
s3://skytrax-reviews-landing-<account-id>/
  raw/
    2024/
      01/
        raw_data_20240101.csv
        raw_data_20240102.csv
      02/
        raw_data_20240201.csv
    ...
  processed/
    2024/
      01/
        clean_data_20240101.csv
        clean_data_20240102.csv
    ...
```

- **Versioning** enabled — protects against accidental overwrites
- **AES256 encryption** — server-side encryption on all objects
- **Lifecycle rules** — transitions to Standard-IA after 30 days, expires old versions after 90 days
- **Public access blocked** — all public access is denied at the bucket level

### Loading Strategy

**Incremental (daily)**: The `skytrax_crawl` DAG runs at 02:00 UTC, scrapes only yesterday's reviews, and uploads to S3. The downstream `skytrax_process` and `skytrax_snowflake` DAGs trigger automatically via Airflow Datasets — no cron, no polling. Each review date maps to exactly one CSV file, so re-runs are idempotent.

**Bulk backfill**: For the initial load, trigger `skytrax_crawl` with `full_scrape=True` to scrape all historical reviews (back to 2010). Snowflake's `COPY INTO` tracks which files have already been loaded, so re-running the bulk load is safe — no duplicates.

### DAGs

| DAG | Trigger | What it does |
| --- | ------- | ------------ |
| `skytrax_crawl` | Daily 02:00 UTC | Scrapes reviews, splits by date, uploads raw CSVs to S3 |
| `skytrax_process` | Dataset (raw) | Downloads raw CSVs, cleans/transforms, uploads processed CSVs |
| `skytrax_snowflake` | Dataset (processed) | Runs COPY INTO Snowflake for each review date |
