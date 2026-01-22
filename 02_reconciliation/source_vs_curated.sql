-- Reconciliation: Source (raw) vs Curated (dim/fact)
-- Goal: prove that curated fact tables reflect the source system correctly for key KPIs.

-- 1) Transaction Count (POSTED) by Month: raw vs fact
WITH raw_monthly AS (
  SELECT
    TO_CHAR(transaction_date, 'YYYY-MM') AS year_month,
    COUNT(DISTINCT transaction_id) AS raw_posted_txn_count,
    SUM(CASE WHEN status = 'POSTED' THEN transaction_amount ELSE 0 END) AS raw_posted_amount,
    SUM(COALESCE(fee_amount, 0)) AS raw_fee_amount
  FROM raw_transactions
  WHERE status = 'POSTED'
  GROUP BY 1
),
fact_monthly AS (
  SELECT
    TO_CHAR(date_key, 'YYYY-MM') AS year_month,
    COUNT(DISTINCT transaction_id) AS fact_posted_txn_count,
    SUM(CASE WHEN status = 'POSTED' THEN transaction_amount ELSE 0 END) AS fact_posted_amount,
    SUM(COALESCE(fee_amount, 0)) AS fact_fee_amount
  FROM fact_transactions
  WHERE status = 'POSTED'
  GROUP BY 1
)
SELECT
  COALESCE(r.year_month, f.year_month) AS year_month,

  r.raw_posted_txn_count,
  f.fact_posted_txn_count,
  (f.fact_posted_txn_count - r.raw_posted_txn_count) AS txn_count_delta,

  r.raw_posted_amount,
  f.fact_posted_amount,
  (f.fact_posted_amount - r.raw_posted_amount) AS posted_amount_delta,

  r.raw_fee_amount,
  f.fact_fee_amount,
  (f.fact_fee_amount - r.raw_fee_amount) AS fee_amount_delta

FROM raw_monthly r
FULL OUTER JOIN fact_monthly f
  ON r.year_month = f.year_month
ORDER BY 1;


-- 2) Active Accounts: raw vs dim_account
WITH raw_active AS (
  SELECT
    COUNT(DISTINCT account_id) AS raw_active_accounts
  FROM raw_accounts
  WHERE account_status = 'ACTIVE'
),
dim_active AS (
  SELECT
    COUNT(DISTINCT account_id) AS dim_active_accounts
  FROM dim_account
  WHERE account_status = 'ACTIVE'
)
SELECT
  raw_active_accounts,
  dim_active_accounts,
  (dim_active_accounts - raw_active_accounts) AS active_account_delta
FROM raw_active, dim_active;


-- 3) Duplicate transaction check (source)
SELECT
  transaction_id,
  COUNT(*) AS record_count
FROM raw_transactions
GROUP BY 1
HAVING COUNT(*) > 1
ORDER BY record_count DESC;


-- 4) Orphan transaction check (fact -> dim_account)
SELECT
  COUNT(*) AS orphan_transactions
FROM fact_transactions ft
LEFT JOIN dim_account da
  ON ft.account_id = da.account_id
WHERE da.account_id IS NULL;
