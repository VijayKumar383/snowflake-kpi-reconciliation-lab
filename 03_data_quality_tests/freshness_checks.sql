-- Data Quality Tests: Freshness & Load Monitoring
-- Purpose: verify that ingestion is current and detect stalled pipelines.

-- 1) Latest load timestamp (raw transactions)
SELECT
  MAX(load_timestamp) AS latest_transaction_load_ts,
  DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) AS hours_since_last_load
FROM raw_transactions;


-- 2) Latest load timestamp (raw accounts)
SELECT
  MAX(load_timestamp) AS latest_account_load_ts,
  DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) AS hours_since_last_load
FROM raw_accounts;


-- 3) Latest load timestamp (raw customers)
SELECT
  MAX(load_timestamp) AS latest_customer_load_ts,
  DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) AS hours_since_last_load
FROM raw_customers;


-- 4) Daily ingestion health (raw_transactions row counts by load date)
SELECT
  load_timestamp::DATE AS load_date,
  COUNT(*) AS rows_loaded
FROM raw_transactions
GROUP BY 1
ORDER BY 1 DESC;


-- 5) Detect stalled days (days with zero loads in the last 14 days)
WITH days AS (
  SELECT DATEADD(day, -seq4(), CURRENT_DATE()) AS d
  FROM TABLE(GENERATOR(ROWCOUNT => 14))
),
loads AS (
  SELECT load_timestamp::DATE AS load_date, COUNT(*) AS rows_loaded
  FROM raw_transactions
  GROUP BY 1
)
SELECT
  d AS expected_date,
  COALESCE(rows_loaded, 0) AS rows_loaded
FROM days
LEFT JOIN loads
  ON days.d = loads.load_date
ORDER BY expected_date DESC;
