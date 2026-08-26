# Retail Intelligence — Project 1

Data analytics project completed as part of the NCPL AI Data Analyst Bootcamp (Cohort 3). Analyzes retail sales data across customers, products, stores, and promotions using SQL and Python to answer real business questions.

**Author:** Henry Nwankwo
**Tools used:** SQL Server (T-SQL), Python (pandas, matplotlib, seaborn), Jupyter Notebook, GitHub Copilot

## Project Structure

```
PROJECT 1/
├── Day 1/   → Data exploration, ER diagram, 15 SQL discovery queries
├── Day 2/   → SQL aggregations & KPIs, KPI definitions sheet, CSV exports
├── Day 3/   → Advanced SQL: RFM analysis, cohort retention, product pairs, YoY growth
├── Day 4/   → Python EDA notebook, 5 visualizations, executive summary
└── ER_Diagram.png
```

## Key Business Questions Answered

1. **Which category and region gives the highest revenue?**
   Electronics is the top-performing category. Dubai is the top-performing city, generating roughly double Abu Dhabi's revenue and more than triple Sharjah's.

2. **How many customers are at risk of leaving?**
   Using RFM segmentation: 276 customers (5.5%) are "At Risk," and a further 756 (15.1%) are already "Lost" — together, roughly 1 in 5 customers need active re-engagement.

3. **Did promotions help increase sales?**
   Yes. Average revenue per transaction was 46.4% higher during promotional periods ($120.44) than outside them ($93.19).

## Techniques Used

- SQL: CTEs, window functions (RANK, ROW_NUMBER, LAG, NTILE), joins, aggregations
- RFM customer segmentation (Recency, Frequency, Monetary)
- Cohort retention analysis
- Market basket analysis (product pairs)
- Python EDA: missing values, duplicates, summary statistics
- Data visualization: line, bar, pie charts, and heatmaps with matplotlib/seaborn

## Deliverables

| Day | Files |
|---|---|
| 1 | `day1_discovery.sql`, ER diagram |
| 2 | `day2_aggregations.sql`, KPI definitions sheet, query result CSVs |
| 3 | `day3_advanced_analytics.sql`, RFM segment summary, cohort retention CSV |
| 4 | `retail_eda.ipynb`, `executive_summary.pdf`, `summary_metrics.csv` |
