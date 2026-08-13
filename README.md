# Titan Financial Analysis Dashboard

A 10-year financial performance dashboard (FY2017–FY2026) analyzing Titan Company's Profit & Loss, Balance Sheet, and Cash Flow statements through a full pre-COVID, COVID, and post-COVID business cycle — built end-to-end from raw Excel financials to an interactive Power BI report.

![Status](https://img.shields.io/badge/status-complete-brightgreen)
![Python](https://img.shields.io/badge/Python-pandas-blue)
![SQL](https://img.shields.io/badge/database-MySQL-orange)
![BI](https://img.shields.io/badge/visualization-Power%20BI-yellow)

---

## Overview

This project analyzes a decade of Titan Company's financial statements to answer the kinds of questions a Financial Analyst is regularly asked to address: How has profitability evolved? How resilient was the business through COVID? Is growth backed by cash, or just reported profit? Is the balance sheet becoming more leveraged?

The project follows a complete analyst workflow: raw data cleaning in Python, structured storage and querying in MySQL, and a final interactive dashboard built in Power BI with a star-schema data model and 35+ custom DAX measures.


## Project Pipeline

```
Raw Excel (Titan Company.xlsx)
        │
        ▼
Python / pandas  →  cleaning, reshaping, derived columns
        │
        ▼
MySQL  →  structured tables (profit_loss, balance_sheet, cash_flow)
        │
        ▼
Power BI  →  star schema data model, DAX measures, 5-page dashboard
```

### 1. Data Cleaning (Python / pandas)

The raw source file (`Titan Company.xlsx`) contained three sheets — Profit & Loss, Balance Sheet, and Cash Flow — with inconsistent headers, extraneous forecast columns, and mixed data types. The cleaning notebook (`Titan_Cleaning.ipynb`):

- Read each sheet with the correct header row and renamed year columns into a consistent `FY20XX` format
- Removed forecast/scenario columns (`Trailing`, `Best Case`, `Worst Case`) not relevant to historical analysis
- Removed fully empty rows and relabeled ambiguous subtotal rows (e.g. renaming a generic "Total" row to `Total_Assets` or `Total_Liabilities_And_Equity` based on its position in the statement)
- Filtered the Profit & Loss sheet down to genuine line items only, discarding header/section rows
- Converted all financial columns to numeric types, coercing invalid entries safely
- Derived two calculated columns directly in Python: `Net_Profit_Margin` and `YoY_Revenue_Growth`
- Exported the cleaned data as both a consolidated Excel workbook and individual CSV files (`Titan_PL.csv`, `Titan_BS.csv`, `Titan_CF.csv`), ready for loading into MySQL

### 2. Database Structure (MySQL)

Three tables were created in a `titan_financial_analysis` database:

- **`profit_loss`** — one row per fiscal year, with Revenue, Expenses, Operating Profit, Net Profit, EBITDA, EPS, and the two Python-derived columns
- **`balance_sheet`** — a wide-format table (one row per line item, one column per fiscal year), including both actual balance sheet amounts and several pre-calculated ratios (Return on Equity, Return on Capital Employed, Debtor Days, Inventory Turnover)
- **`cash_flow`** — a wide-format table of the four cash flow categories (Operating, Investing, Financing, Net Cash Flow) across all 10 years

A `titan_financial_summary` view was also created as a simplified subset of the P&L table for early testing (this view was not carried forward into the final Power BI model — see the technical decisions below).

### 3. Dashboard Development (Power BI)

The three MySQL tables were reshaped into a proper star schema and used to build a 5-page interactive dashboard with 35+ custom DAX measures. Full details are in the [project documentation](./docs/Titan_Dashboard_Documentation.docx).

---

## Dashboard Pages

| Page | What it covers |
|---|---|
| **Executive Summary** | 10-year KPI overview — Revenue, Net Profit, CAGR, EBITDA Margin, ROE, Net Cash Flow, YoY growth |
| **Revenue & Profitability** | Growth trends, margin stability, and a Pre-COVID / COVID / Post-COVID performance comparison |
| **Balance Sheet Health** | Asset growth, capital structure, and the trend in financial leverage (Debt-to-Equity) |
| **Ratio & Efficiency Analysis** | ROE vs. ROCE, EBITDA Interest Coverage, Debtor Days, Inventory Turnover |
| **Cash Flow Analysis** | Operating / Investing / Financing cash flows and earnings quality (Cash Conversion Ratio) |

---

## Key Insights

- Revenue grew from ₹13,260 Cr (FY17) to ₹87,584 Cr (FY26) — a 23.3% CAGR — with growth slowing to single digits during COVID (FY20–21) before accelerating to 33–41% in the recovery years (FY22–23).
- ROE nearly doubled over the decade (17% → 32%), while ROCE reached only 20% in FY26 — the widening gap reflects a significant rise in financial leverage, with Debt-to-Equity increasing from 0.44x to 1.95x.
- Despite 6x+ revenue growth, EBITDA margin stayed within a stable 9.6%–13.4% band across the full decade.
- Cash Conversion Ratio was highly volatile year to year (-0.33x to 4.3x), showing that reported profit and actual cash generated do not always move together — a genuine earnings-quality signal, not a data error.

---

## Power BI Data Model

The three MySQL tables were reshaped and modeled into a star schema with one central date dimension and four fact tables:

```
                    ┌─────────────────────┐
                    │   Dim_Fiscal_year    │
                    │  (10 rows, FY17-26)  │
                    └──────────┬──────────┘
             ┌──────────┬──────┼──────┬──────────┐
             │          │             │          │
    titan_profit_loss  titan_balance_sheet  titan_b/s_Ratios  titan_cash_flow
       (1:1, 10 rows)   (1:many, 130 rows)   (1:many, 40 rows) (1:many, 40 rows)
```

- **Dim_Fiscal_year** — the central dimension: `Fiscal_Year` (text), `Year` (numeric, for chronological sorting), `Covid_Period` (Pre-COVID / COVID / Post-COVID)
- **titan_profit_loss** — loaded directly from the MySQL table; one row per year
- **titan_balance_sheet** — the wide-format MySQL table was unpivoted in Power Query into a long format (`Narration`, `Fiscal_Year`, `Amount_Cr`)
- **titan_b/s_Ratios** — the 4 pre-calculated ratios (ROE, ROCE, Debtor Days, Inventory Turnover) were split out of the balance sheet table into their own table, to avoid mixing currency amounts with ratios/percentages in the same column
- **titan_cash_flow** — unpivoted from wide to long format, same treatment as the balance sheet

---

## Tech Stack

- **Python (pandas)** — data cleaning, reshaping, and derived-column calculation
- **MySQL** — structured storage and initial exploratory querying
- **Power BI Desktop** — data modeling, DAX measures, dashboard design (free/community edition; no Power BI Service features used)
- **DAX** — 35+ custom measures, including CAGR, dynamic "latest year" logic, and period-over-baseline variance analysis

---

## Notable Technical Decisions

- **Self-updating "latest year" measures** — built using `MAX()` rather than a hardcoded year, so KPI cards continue to work correctly as new fiscal years are added, with no formula changes required.
- **Stock vs. flow separation** — Balance Sheet KPI cards are explicitly restricted to a single fiscal year, since summing point-in-time figures (like Total Assets) across multiple years produces a meaningless number — unlike flow figures (like Revenue), which can be meaningfully totaled.
- **COVID integrated into the model, not a separate page** — a `Covid_Period` column on the date dimension allows any page to group and compare Pre-COVID / COVID / Post-COVID performance directly, rather than isolating COVID analysis into its own view.
- **The `titan_financial_summary` SQL view was excluded from the Power BI model** — it duplicated columns already present in `profit_loss`, and loading both would have created a redundant, overlapping table in the data model.
- **Free Cash Flow intentionally excluded** — the source data does not include a clean, direct Capital Expenditure figure, and rather than approximate one, this measure was left out so that every number on the dashboard can be confidently explained and defended.

---

## Repository Contents

```
├── power-bi/
│   └── Titan_Financial_Analysis.pbix        # Power BI report file
├── python/
│   └── Titan_Cleaning.ipynb                 # Data cleaning notebook
├── sql/
│   └── Titan_SQL_Queries.sql                # Table creation and source queries
├── data/
│   ├── Titan_PL.csv
│   ├── Titan_BS.csv
│   └── Titan_CF.csv
├── docs/
│   └── Titan_Dashboard_Documentation.docx   # Full write-up: data model, DAX reference, glossary, interview prep
├── screenshots/
│   └── (dashboard page images)
├── LICENSE
└── README.md
```

---

## About This Project

Built as a portfolio project to demonstrate practical financial analysis, data cleaning, and data modeling skills for Financial Analyst, FP&A Analyst, and Data Analyst roles. 
**Author:** Sreelakshmi K.A.

---

## Data Source & Disclaimer

Financial figures are based on Titan Company Limited's publicly available financial statements, used here strictly for educational and portfolio demonstration purposes. This project is not affiliated with, endorsed by, or representative of Titan Company Limited.
