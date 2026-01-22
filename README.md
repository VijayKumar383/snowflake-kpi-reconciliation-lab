# Snowflake KPI Reconciliation & Decision Trust Lab

This repository simulates a production-grade analytics validation workflow used in financial services environments, where executive decisions depend on the accuracy, consistency, and traceability of key performance indicators (KPIs).

The focus is not on building dashboards or models in isolation, but on answering a more critical question:

> When numbers differ across systems, which one is correct, why do they differ, and how do we prove the truth before leadership acts on it?

This lab demonstrates how raw transactional data, curated warehouse layers, and executive reporting views are reconciled, validated, and governed to produce decision-ready metrics in Snowflake.

---

## Business Context

In payments and portfolio environments, leadership reviews KPIs such as:

- Total transaction volume
- Active accounts
- Delinquency and charge-off rates
- Revenue and fee income
- Month-over-month and cohort trends

These metrics often originate from multiple operational systems and are transformed through several layers before appearing in executive dashboards. Discrepancies can arise due to:

- Late-arriving data
- Duplicate or missing records
- Inconsistent business rules
- Grain mismatches
- Aggregation and filtering logic differences
- Refresh timing and cutoff misalignment

This project reproduces that reality and shows how an enterprise Data Analyst validates, reconciles, and certifies KPIs before they are trusted in leadership and risk reviews.

---

## Objectives

1. Trace executive KPIs from dashboard layer back to Snowflake source tables  
2. Reconcile counts, balances, rates, and trends across data layers  
3. Identify and explain variance drivers  
4. Establish consistent metric definitions and lineage  
5. Implement data quality and audit-readiness checks  
6. Produce documentation that allows metrics to be defended under review  

---

## Analytical Architecture

The simulated data flow follows a common enterprise pattern:

Source Systems  
→ Raw Ingestion Layer (Snowflake)  
→ Curated Dimensional Model  
→ Semantic / Metric Layer  
→ Executive BI & Reporting

Each layer introduces potential for transformation error, timing mismatch, or logic drift. This repository focuses on validating transitions between these layers.

---

## Repository Structure

snowflake-kpi-reconciliation-lab/
│
├── 00_business_context/
│   └── problem_statement.md
│
├── 01_data_model/
│   ├── source_schema.sql
│   ├── dimensional_model.sql
│   └── metric_definitions.md
│
├── 02_reconciliation/
│   ├── source_vs_curated.sql
│   ├── curated_vs_exec.sql
│   └── variance_attribution.sql
│
├── 03_data_quality_tests/
│   ├── row_count_checks.sql
│   ├── balance_checks.sql
│   ├── null_anomaly_tests.sql
│   └── freshness_checks.sql
│
├── 04_analysis_notebooks/
│   ├── variance_investigation.ipynb
│   └── trend_break_analysis.ipynb
│
├── 05_visualization/
│   └── executive_kpi_dashboard/
│
├── 06_architecture/
│   ├── data_flow_diagram.png
│   └── lineage_diagram.png
│
├── 07_governance/
│   ├── kpi_contracts.md
│   └── audit_readiness.md
│
└── README.md
