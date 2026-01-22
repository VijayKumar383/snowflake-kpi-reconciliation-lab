-- Curated dimensional model (simulated reporting layer)

-- Dimensions
CREATE OR REPLACE TABLE dim_date AS
SELECT
  d::DATE AS date_key,
  YEAR(d) AS year,
  MONTH(d) AS month,
  TO_CHAR(d, 'YYYY-MM') AS year_month
FROM (
  SELECT DATEADD(day, seq4(), '2024-01-01') AS d
  FROM TABLE(GENERATOR(ROWCOUNT => 730))
);

CREATE OR REPLACE TABLE dim_customer AS
SELECT
  customer_id,
  customer_segment,
  region,
  join_date
FROM raw_customers;

CREATE OR REPLACE TABLE dim_account AS
SELECT
  a.account_id,
  a.customer_id,
  a.open_date,
  a.close_date,
  a.account_status,
  a.credit_limit
FROM raw_accounts a;

-- Fact table (transaction grain)
CREATE OR REPLACE TABLE fact_transactions AS
SELECT
  t.transaction_id,
  t.account_id,
  a.customer_id,
  t.transaction_date AS date_key,
  t.transaction_amount,
  t.transaction_type,
  t.status,
  t.fee_amount,
  t.load_timestamp
FROM raw_transactions t
LEFT JOIN raw_accounts a
  ON t.account_id = a.account_id;

-- Curated monthly KPI summary (semantic/exec-facing layer simulation)
CREATE OR REPLACE TABLE kpi_monthly_portfolio AS
SELECT
  d.year_month,
  COUNT(DISTINCT CASE WHEN a.account_status = 'ACTIVE' THEN a.account_id END) AS active_accounts,
  COUNT(DISTINCT t.transaction_id) AS transaction_count,
  SUM(CASE WHEN t.status = 'POSTED' THEN t.transaction_amount ELSE 0 END) AS posted_transaction_amount,
  SUM(COALESCE(t.fee_amount, 0)) AS total_fee_amount
FROM dim_date d
LEFT JOIN fact_transactions t
  ON d.date_key = t.date_key
LEFT JOIN dim_account a
  ON t.account_id = a.account_id
GROUP BY 1;
