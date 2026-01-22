-- Variance Attribution Playbook
-- Goal: When KPI deltas exist, break variance into explainable buckets:
--   1) Late-arriving records (load timing)
--   2) Status changes (POSTED vs REVERSED/PENDING)
--   3) Duplicate IDs
--   4) Orphaned joins (transactions missing account mapping)
--   5) Cutoff mismatch (month boundary effects)

-- =========================
-- 1) Late-Arriving Records
-- =========================
-- Records whose transaction_date is in an earlier month but load_timestamp is later.
-- These often cause KPI shifts after executive certification.

SELECT
  TO_CHAR(transaction_date, 'YYYY-MM') AS txn_month,
  TO_CHAR(load_timestamp::DATE, 'YYYY-MM') AS load_month,
  COUNT(*) AS late_arriving_rows,
  SUM(transaction_amount) AS late_arriving_amount
FROM raw_transactions
WHERE status = 'POSTED'
  AND TO_CHAR(load_timestamp::DATE, 'YYYY-MM') > TO_CHAR(transaction_date, 'YYYY-MM')
GROUP BY 1, 2
ORDER BY 1, 2;


-- ==================================
-- 2) Status Drift / Status Flip Check
-- ==================================
-- Transactions that exist but are not POSTED (reversed/pending/etc.)
-- This explains count/amount deltas when one layer filters differently.

SELECT
  status,
  COUNT(DISTINCT transaction_id) AS txn_count,
  SUM(transaction_amount) AS txn_amount
FROM raw_transactions
GROUP BY 1
ORDER BY txn_count DESC;


-- =====================================
-- 3) Duplicate Transaction ID Detection
-- =====================================
-- Duplicate transaction_id is a common root cause of over-counting.

SELECT
  transaction_id,
  COUNT(*) AS duplicate_records
FROM raw_transactions
GROUP BY 1
HAVING COUNT(*) > 1
ORDER BY duplicate_records DESC;


-- ==========================================
-- 4) Orphan Transactions (Join Integrity)
-- ==========================================
-- Transactions whose account_id does not exist in account master
-- This creates discrepancies between raw totals and curated totals after joining.

SELECT
  COUNT(*) AS orphan_txn_rows,
  SUM(transaction_amount) AS orphan_txn_amount
FROM raw_transactions t
LEFT JOIN raw_accounts a
  ON t.account_id = a.account_id
WHERE a.account_id IS NULL;


-- ===================================================
-- 5) Cutoff Boundary Effects (Month End / Month Start)
-- ===================================================
-- Transactions posted near month-end can land in different months depending on:
-- - transaction_date vs posting timestamp interpretation
-- - timezone conversions
-- - batch posting windows
-- This query surfaces records near boundaries for investigation.

SELECT
  transaction_date,
  COUNT(*) AS txn_rows,
  SUM(transaction_amount) AS txn_amount
FROM raw_transactions
WHERE status = 'POSTED'
  AND (
    DAY(transaction_date) IN (1, 2, 28, 29, 30, 31)
  )
GROUP BY 1
ORDER BY 1;


-- ===================================================
-- 6) Executive Layer Delta Drill (Month-level)
-- ===================================================
-- When you see a delta for a given month, this helps drill down:
-- Compare curated_calc vs exec and flag mismatched months.

WITH curated_calc AS (
  SELECT
    TO_CHAR(ft.date_key, 'YYYY-MM') AS year_month,
    COUNT(DISTINCT CASE WHEN ft.status = 'POSTED' THEN ft.transaction_id END) AS txn_count_curated,
    SUM(CASE WHEN ft.status = 'POSTED' THEN ft.transaction_amount ELSE 0 END) AS posted_amount_curated
  FROM fact_transactions ft
  GROUP BY 1
),
exec_layer AS (
  SELECT
    year_month,
    transaction_count AS txn_count_exec,
    posted_transaction_amount AS posted_amount_exec
  FROM kpi_monthly_portfolio
),
delta AS (
  SELECT
    COALESCE(c.year_month, e.year_month) AS year_month,
    c.txn_count_curated,
    e.txn_count_exec,
    (e.txn_count_exec - c.txn_count_curated) AS txn_count_delta,
    c.posted_amount_curated,
    e.posted_amount_exec,
    (e.posted_amount_exec - c.posted_amount_curated) AS posted_amount_delta
  FROM curated_calc c
  FULL OUTER JOIN exec_layer e
    ON c.year_month = e.year_month
)
SELECT *
FROM delta
WHERE txn_count_delta <> 0 OR posted_amount_delta <> 0
ORDER BY year_month;
