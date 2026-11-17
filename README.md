# US Consumer Finance Complaints & Service Performance

**PostgreSQL | SQL Analytics | Financial Services | United States | January–March 2025**

## Project Overview

This project analyses **50,430 consumer complaints** from the US Consumer Financial Protection Bureau (CFPB) relating to **checking or savings accounts** and **credit cards** between **1 January and 31 March 2025**. The objective is to identify complaint trends, compare company response timeliness, highlight fast-growing and persistent issues, and prioritise company–product–state combinations for operational investigation.

**Data source:** [CFPB Consumer Complaint Database](https://www.consumerfinance.gov/data-research/consumer-complaints/) — a public database of consumer-submitted complaints. The dataset used here is a filtered historical extract, not the full CFPB database.

**Tools:** PostgreSQL, DBeaver, CSV.  
**Techniques:** CTEs, `LAG()`, `DENSE_RANK()`, `SUM() OVER`, conditional aggregation with `FILTER`, `NULLIF()`, `COALESCE()`, and UTC-aware date handling.

## SQL Analyses and Results

| # | Business question | SQL query | CSV results |
|---|---|---|---|
| 01 | How did complaint volumes change by banking product each month? | [Product complaint trends](sql_queries/01_product_complaint_trends.sql) | [View results](results/01_product_complaint_trends.csv) |
| 02 | Which companies recorded the most untimely responses and the highest untimely-response rates? | [Company response timeliness](sql_queries/02_company_response_timeliness.sql) | [View results](results/02_company_response_timeliness.csv) |
| 03 | Which complaint issues increased most and which remained high-volume? | [Emerging and persistent issues](sql_queries/03_emerging_and_persistent_issues.sql) | [View results](results/03_emerging_and_persistent_issues.csv) |
| 04 | Which company–product–state combinations warrant investigation? | [Geographic risk prioritisation](sql_queries/04_geographic_risk_prioritisation.sql) | [View results](results/04_geographic_risk_prioritisation.csv) |

**Setup:** [Create the `complaints_clean` view](sql_queries/00_create_complaints_clean_view.sql)

## Key Findings

- **Product trends:** Checking or savings accounts generated **28,889 complaints (57%)**, compared with **21,541 (43%)** for credit cards. January accounted for **27,440 complaints (54% of the quarter)**. The sharp February decline in checking/savings complaints should not be interpreted as proof of better service.
- **Response timeliness:** Among companies with at least 30 complaints, **Block** recorded the most untimely responses (**31; 2.6%**), while **Robinhood** had the highest untimely-response rate (**10.7%**).
- **Issue trends:** Credit-card complaints about incorrect credit-report information increased **42.5%** from February to March. Account-management complaints (**13,839 quarterly**) and purchase disputes (**4,124**) remained major recurring issues.
- **Geographic priorities:** Block's checking/savings complaints in **Florida (5 of 70 untimely; 7.1%)** and **Georgia (4 of 76; 5.3%)** are priority combinations for investigation.

These patterns indicate where further investigation may be worthwhile; they do not establish the causes of complaints or the overall quality of individual companies' service.

## Recommendations

Monitor complaint volume by company, product and issue; investigate unusual spikes promptly. Review reported response delays in Block's Florida and Georgia cases and Robinhood's response processes. Investigate credit-reporting errors and assign operational owners to recurring high-volume issues. Assess both absolute complaint counts and rates rather than relying on a single ranking.

For fuller discussion, see the [executive summary](business_insights/executive_summary.md) and [all four business findings](business_insights/key_findings.md).

## Data Preparation and Reproducibility

1. Download a CFPB complaint CSV filtered to **1 January–31 March 2025**, **Credit card** and **Checking or savings account**. The CFPB database can change over time, so a new extract may not exactly reproduce these results.
2. Import the original CSV into a PostgreSQL table named `public.complaints`, retaining the **original source headers exactly** (including spaces and punctuation). The source dates were imported as text; `"Complaint ID"` was stored as a `BIGINT` primary key.
3. Run [`00_create_complaints_clean_view.sql`](sql_queries/00_create_complaints_clean_view.sql). This creates a view with analysis-friendly column names and timestamp conversion. **The setup script does not create or load the raw complaints table.**
4. Run the four numbered query files in order and compare their output with the linked CSVs. Date grouping and date filters use **UTC** where required.

The underlying raw complaint extract is not included in this repository. Download it from the CFPB source before running the setup.

## Scope and Limitations

- This covers **three months** and two selected financial-product categories; it is not representative of all financial complaints or all US customers.
- CFPB complaint counts are not normalised by company customer base, product holdings or state population.
- Timeliness records whether a company responded within the applicable deadline; it does **not** measure resolution quality or customer satisfaction. Missing timeliness statuses are excluded from rate denominators.
- State-level untimely-response counts can be small, so rankings are **investigation priorities**, not definitive risk scores.
- An additional investigation noted a concentration of January checking/savings complaints involving Navy Federal Credit Union and Capital One. The four published summary queries do not independently reproduce that company-and-issue drill-down.

## Repository Structure

```text
us-consumer-finance-complaints-analysis/
├── README.md
├── sql_queries/
│   ├── 00_create_complaints_clean_view.sql
│   ├── 01_product_complaint_trends.sql
│   ├── 02_company_response_timeliness.sql
│   ├── 03_emerging_and_persistent_issues.sql
│   └── 04_geographic_risk_prioritisation.sql
├── results/
│   ├── 01_product_complaint_trends.csv
│   ├── 02_company_response_timeliness.csv
│   ├── 03_emerging_and_persistent_issues.csv
│   └── 04_geographic_risk_prioritisation.csv
└── business_insights/
    ├── executive_summary.md
    └── key_findings.md
```
