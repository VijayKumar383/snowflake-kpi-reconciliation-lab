-- Data Quality Tests: Balance & Control Totals
-- Purpose: ensure amounts reconcile across layers and catch drift early.

-- 1) Control totals: Raw (POSTED) vs Fact (POSTED)
WITH raw_totals AS (
  SELECT
    COUNT(DISTINCT transaction_id) AS raw_posted_txn_count,
    SUM(transaction_amount) AS raw_posted_amount,
    SUM(COALESCE(fee_amount, 0)) AS raw_fee_amount
  FROM raw_transactions
  WHERE status = 'POSTED'
),
fact_totals AS (
  SELECT
    COUNT(DISTINCT transaction_id) AS fact_posted_txn_count,
    SUM(transaction_amount) AS fact_posted_amount,
    SUM(COALESCE(fee_amount, 0)) AS fact_fee_amount
  FROM fact_transactions
  WHERE status = 'POSTED'
)
SELECT
  r.raw_posted_txn_count,
  f.fact_posted_txn_count,
  (f.fact_posted_txn_count - r.raw_posted_txn_count) AS txn_count_delta,

  r.raw_posted_amount,
  f.fact_posted_amount,
  (f.fact_posted_amount - r.raw_posted_amount) AS posted_amount_delta,

  r.raw_fee_amount,
  f.fact_fee_amount,
  (f.fact_fee_amount - r.raw_fee_amount) AS fee_amount_delta
FROM raw_totals r, fact_totals f;


-- 2) Executive layer vs curated KPI totals
WITH curated AS (
  SELECT
    SUM(CASE WHEN status = 'POSTED' THEN transaction_amount ELSE 0 END) AS curated_posted_amount,
    SUM(COALESCE(fee_amount, 0)) AS curated_fee_amount
  FROM fact_transactions
),
exec AS (
  SELECT
    SUM(posted_transaction_amount) AS exec_posted_amount,
    SUM(total_fee_amount) AS exec_fee_amount
  FROM kpi_monthly_portfolio
)
SELECT
  curated_posted_amount,
  exec_posted_amount,
  (exec_posted_amount - curated_posted_amount) AS posted_amount_delta,

  curated_fee_amount,
  exec_fee_amount,
  (exec_fee_amount - curated_fee_amount) AS fee_amount_delta
FROM curated, exec;


-- 3) Negative amount guardrails (finance sanity)
SELECT
  COUNT(*) AS negative_posted_transactions
FROM raw_transactions
WHERE status = 'POSTED'
  AND transaction_amount < 0;


-- 4) High outlier detection (simple statistical guardrail)
-- Flags unusually large transactions for investigation.
WITH stats AS (
  SELECT
    AVG(transaction_amount) AS avg_amt,
    STDDEV(transaction_amount) AS std_amt
  FROM raw_transactions
  WHERE status = 'POSTED'
)
SELECT
  t.transaction_id,
  t.account_id,
  t.transaction_date,
  t.transaction_amount
FROM raw_transactions t, stats s
WHERE t.status = 'POSTED'
  AND t.transaction_amount > (s.avg_amt + 5 * s.std_amt)
ORDER BY t.transaction_amount DESC;
