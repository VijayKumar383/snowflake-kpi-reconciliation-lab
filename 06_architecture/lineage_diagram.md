# KPI Lineage & Traceability (Decision Trust Layer)

This diagram illustrates how executive KPIs are traceable from dashboard metrics back to curated models and raw source systems.

```mermaid
flowchart LR
  A[raw_transactions.amount] --> B[fact_transactions.amount]
  B --> C[kpi_monthly_portfolio.total_volume]
  C --> D[Executive Dashboard: Total Volume KPI]

  E[raw_accounts.status] --> F[dim_account.status]
  F --> G[kpi_monthly_portfolio.active_accounts]
  G --> H[Executive Dashboard: Active Accounts KPI]

  I[raw_transactions.charge_off_flag] --> J[fact_transactions.charge_off_flag]
  J --> K[kpi_monthly_portfolio.charge_off_rate]
  K --> L[Risk Committee Review]
