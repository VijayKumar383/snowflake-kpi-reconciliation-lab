# Data Flow Architecture (Snowflake KPI Decision Trust Lab)

This diagram shows how data moves from raw ingestion → curated modeling → KPI semantic layer → executive reporting.

```mermaid
flowchart LR
  A[Source Systems] --> B[Raw Ingestion Layer\n(raw_transactions, raw_accounts, raw_customers)]
  B --> C[Curated Dimensional Model\n(dim_account, dim_customer, fact_transactions)]
  C --> D[Semantic / KPI Layer\n(kpi_monthly_portfolio)]
  D --> E[Executive BI & Decision Reviews]

  B --> F[Data Quality Tests\n03_data_quality_tests/*]
  C --> G[Reconciliation\n02_reconciliation/*]
  D --> H[Variance Attribution\nvariance_attribution.sql]

  F --> I[Alert / Investigation]
  G --> I
  H --> I
