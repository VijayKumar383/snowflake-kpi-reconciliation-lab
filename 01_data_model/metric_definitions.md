# KPI Definitions & Calculation Contracts

This document defines the executive-facing KPIs used in this repository, including their business meaning, calculation logic, grain, and reconciliation rules.

Each KPI is treated as a contract: a fixed definition that must remain consistent across source, curated, and executive layers.

---

## 1. Active Accounts

**Business Definition:**  
Number of distinct accounts in ACTIVE status during the reporting period.

**Grain:**  
Account-level, aggregated to month.

**Calculation Logic:**  
COUNT(DISTINCT account_id)  
WHERE account_status = 'ACTIVE'

**Source Tables:**  
raw_accounts  
dim_account

**Reconciliation Rules:**  
- Source vs Dim count must match within same as-of date
- Excludes closed and suspended accounts
- Cutoff based on account_status as of month-end

---

## 2. Transaction Count

**Business Definition:**  
Total number of posted transactions during the reporting period.

**Grain:**  
Transaction-level, aggregated to month.

**Calculation Logic:**  
COUNT(DISTINCT transaction_id)  
WHERE status = 'POSTED'

**Source Tables:**  
raw_transactions  
fact_transactions

**Reconciliation Rules:**  
- No duplicate transaction_id
- Excludes reversed and pending transactions
- Posting date aligned to date_key in dim_date

---

## 3. Posted Transaction Amount

**Business Definition:**  
Total monetary value of posted transactions in the period.

**Grain:**  
Transaction-level, aggregated to month.

**Calculation Logic:**  
SUM(transaction_amount)  
WHERE status = 'POSTED'

**Reconciliation Rules:**  
- Sum at fact layer must equal semantic layer totals
- Variance explained by late-arriving or reversed transactions
- Currency assumed consistent (single-currency simulation)

---

## 4. Fee Revenue

**Business Definition:**  
Total fees charged on posted transactions.

**Calculation Logic:**  
SUM(fee_amount)

**Reconciliation Rules:**  
- Null fees treated as zero
- Outliers flagged via anomaly detection
- Monthly totals must reconcile to GL control totals (simulated)

---

## Governance & Change Control

- All KPI logic changes require:
  - Updated definition
  - Updated reconciliation queries
  - Variance impact assessment
- Refresh cadence: Daily load, Monthly executive certification
- Lineage documented from raw → fact → semantic → dashboard
