-- Data Quality Tests: Nulls, Category Validations, and Anomaly Flags
-- Purpose: detect schema drift, unexpected values, and data corruption early.

-- 1) Null checks by column (raw_transactions)
SELECT
  SUM(CASE WHEN transaction_id IS NULL THEN 1 ELSE 0 END) AS null_transaction_id,
  SUM(CASE WHEN account_id IS NULL THEN 1 ELSE 0 END) AS null_account_id,
  SUM(CASE WHEN transaction_date IS NULL THEN 1 ELSE 0 END) AS null_transaction_date,
  SUM(CASE WHEN transaction_amount IS NULL THEN 1 ELSE 0 END) AS null_transaction_amount,
  SUM(CASE WHEN status IS NULL THEN 1 ELSE 0 END) AS null_status
FROM raw_transactions;


-- 2) Unexpected status values (domain enforcement)
-- In real environments, new/unexpected statuses can break KPI logic.
SELECT
  status,
  COUNT(*) AS row_count
FROM raw_transactions
GROUP BY 1
ORDER BY row_count DESC;


-- 3) Unexpected transaction_type values
SELECT
  transaction_type,
  COUNT(*) AS row_count
FROM raw_transactions
GROUP BY 1
ORDER BY row_count DESC;


-- 4) Fee integrity checks (fees should not exceed amount in most contexts)
SELECT
  transaction_id,
  transaction_amount,
  fee_amount
FROM raw_transactions
WHERE fee_amount IS NOT NULL
  AND transaction_amount IS NOT NULL
  AND ABS(fee_amount) > ABS(transaction_amount)
ORDER BY ABS(fee_amount) DESC;


-- 5) Account master integrity checks
SELECT
  SUM(CASE WHEN account_id IS NULL THEN 1 ELSE 0 END) AS null_account_id,
  SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
  SUM(CASE WHEN account_status IS NULL THEN 1 ELSE 0 END) AS null_account_status
FROM raw_accounts;


-- 6) Duplicates in account master
SELECT
  account_id,
  COUNT(*) AS record_count
FROM raw_accounts
GROUP BY 1
HAVING COUNT(*) > 1
ORDER BY record_count DESC;


-- 7) Orphan relationships: accounts with missing customers
SELECT
  COUNT(*) AS accounts_missing_customer
FROM raw_accounts a
LEFT JOIN raw_customers c
  ON a.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
