# KPI Contracts & Metric Governance

This document defines formal contracts for executive KPIs to ensure consistency, auditability, and decision safety.

---

## KPI: Total Transaction Volume

**Business Definition:**  
Total monetary value of all posted transactions within the reporting period.

**Source Tables:**  
- raw_transactions.amount  
- fact_transactions.amount  

**Semantic Layer:**  
- kpi_monthly_portfolio.total_volume  

**Grain:**  
Monthly, Portfolio Level

**Calculation Logic:**  
SUM(fact_transactions.amount)  
Filtered to:  
- posted_flag = TRUE  
- transaction_date between period_start and period_end  

**Refresh Cadence:**  
Daily (T+1), Executive Reporting uses Month-End Snapshot

**Known Reconciliation Checks:**  
- Source vs Curated row counts  
- Source vs Curated amount sums  
- Curated vs Semantic aggregation parity  

**Variance Drivers:**  
- Late-arriving transactions  
- Reprocessing adjustments  
- Backdated postings  

---

## KPI: Active Accounts

**Business Definition:**  
Count of unique accounts with at least one posted transaction in the reporting period.

**Source Tables:**  
- raw_accounts  
- fact_transactions  

**Semantic Layer:**  
- kpi_monthly_portfolio.active_accounts  

**Grain:**  
Monthly, Portfolio Level

**Calculation Logic:**  
COUNT(DISTINCT account_id)  
Where transaction_count >= 1 in period

**Data Quality Controls:**  
- Null account_id checks  
- Duplicate account suppression  
- Status consistency validation

---

## KPI: Charge-Off Rate

**Business Definition:**  
Percentage of total outstanding balance that has been charged off in the period.

**Source Tables:**  
- raw_transactions.charge_off_flag  
- fact_transactions.balance  

**Semantic Layer:**  
- kpi_monthly_portfolio.charge_off_rate  

**Calculation Logic:**  
SUM(charge_off_balance) / SUM(total_balance)

**Audit Controls:**  
- Balance tie-out to GL  
- Rate reconciliation to risk system  
- Historical trend drift detection
