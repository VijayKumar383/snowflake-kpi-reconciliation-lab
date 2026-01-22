-- Reconciliation: Curated (fact/dim) vs Executive KPI Layer (kpi_monthly_portfolio)
-- Goal: prove that the semantic/exec layer matches curated calculations.

-- 1) Compare monthly metrics: curated calc vs executive table
WITH curated_calc AS (
  SELECT
    TO_CHAR(ft.date_key, 'YYYY-MM') AS year_month,
    COUNT(DISTINCT CASE WHEN da.account_status = 'ACTIVE' THEN da.account_id END) AS active_accounts_curated,
    COUNT(DISTINCT CASE WHEN ft.status = 'POSTED' THEN ft.transaction_id END) AS transaction_count_curated,
    SUM(CASE WHEN ft.status = 'POSTED' THEN ft.transaction_amount ELSE 0 END) AS posted_transaction_amount_curated,
    SUM(COALESCE(ft.fee_amount, 0)) AS total_fee_amount_curated
  FROM fact_transactions ft
  LEFT JOIN dim_account da
    ON ft.account_id = da.account_id
  GROUP BY 1
),
exec_layer AS (
  SELECT
    year_month,
    active_accounts AS active_accounts_exec,
    transaction_count AS transaction_count_exec,
    posted_transaction_amount AS posted_transaction_amount_exec,
    total_fee_amount AS total_fee_amount_exec
  FROM kpi_monthly_portfolio
)
SELECT
  COALESCE(c.year_month, e.year_month) AS year_month,

  c.active_accounts_curated,
  e.active_accounts_exec,
  (e.active_accounts_exec - c.active_accounts_curated) AS active_accounts_delta,

  c.transaction_count_curated,
  e.transaction_count_exec,
  (e.transaction_count_exec - c.transaction_count_curated) AS transaction_count_delta,

  c.posted_transaction_amount_curated,
  e.posted_transaction_amount_exec,
  (e.posted_transaction_amount_exec - c.posted_transaction_amount_curated) AS posted_amount_delta,

  c.total_fee_amount_curated,
  e.total_fee_amount_exec,
  (e.total_fee_amount_exec - c.total_fee_amount_curated) AS fee_amount_delta

FROM curated_calc c
FULL OUTER JOIN exec_layer e
  ON c.year_month = e.year_month
ORDER BY 1;


-- 2) Completeness check: months present in curated but missing in exec (and vice versa)
WITH curated_months AS (
  SELECT DISTINCT TO_CHAR(date_key, 'YYYY-MM') AS year_month
  FROM fact_transactions
),
exec_months AS (
  SELECT DISTINCT year_month
  FROM kpi_monthly_portfolio
)
SELECT
  'Missing in Exec Layer' AS issue_type,
  c.year_month
FROM curated_months c
LEFT JOIN exec_months e
  ON c.year_month = e.year_month
WHERE e.year_month IS NULL

UNION ALL

SELECT
  'Missing in Curated Layer' AS issue_type,
  e.year_month
FROM exec_months e
LEFT JOIN curated_months c
  ON e.year_month = c.year_month
WHERE c.year_month IS NULL
ORDER BY 1, 2;


-- 3) Basic sanity checks: negative totals or impossible values (guardrails)
SELECT
  year_month,
  active_accounts,
  transaction_count,
  posted_transaction_amount,
  total_fee_amount
FROM kpi_monthly_portfolio
WHERE posted_transaction_amount < 0
   OR total_fee_amount < 0
   OR transaction_count < 0
   OR active_accounts < 0
ORDER BY year_month;
