-- Data Quality Tests: Row Count & Completeness Checks
-- Purpose: validate ingestion completeness and prevent silent drops.

-- 1) Daily row count trend (raw transactions)
SELECT
  transaction_date,
  COUNT(*) AS row_count,
  COUNT(DISTINCT transaction_id) AS distinct_txn_ids
FROM raw_transactions
GROUP BY 1
ORDER BY 1;


-- 2) Monthly row count trend (raw transactions)
SELECT
  TO_CHAR(transaction_date, 'YYYY-MM') AS year_month,
  COUNT(*) AS row_count,
  COUNT(DISTINCT transaction_id) AS distinct_txn_ids
FROM raw_transactions
GROUP BY 1
ORDER BY 1;


-- 3) Fact vs Raw row counts (should be explainable)
SELECT
  (SELECT COUNT(*) FROM raw_transactions) AS raw_txn_rows,
  (SELECT COUNT(*) FROM fact_transactions) AS fact_txn_rows,
  ((SELECT COUNT(*) FROM fact_transactions) - (SELECT COUNT(*) FROM raw_transactions)) AS row_delta;


-- 4) Transactions missing critical fields (completeness)
SELECT
  COUNT(*) AS missing_critical_fields
FROM raw_transactions
WHERE transaction_id IS NULL
   OR account_id IS NULL
   OR transaction_date IS NULL
   OR transaction_amount IS NULL;
