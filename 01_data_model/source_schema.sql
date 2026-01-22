-- Source system schema (simulated transactional layer)

CREATE OR REPLACE TABLE raw_transactions (
    transaction_id      STRING,
    account_id          STRING,
    transaction_date    DATE,
    transaction_amount  NUMBER(18,2),
    transaction_type    STRING,
    status              STRING,
    fee_amount          NUMBER(18,2),
    load_timestamp      TIMESTAMP
);

CREATE OR REPLACE TABLE raw_accounts (
    account_id          STRING,
    customer_id         STRING,
    open_date           DATE,
    close_date          DATE,
    account_status      STRING,
    credit_limit        NUMBER(18,2),
    load_timestamp      TIMESTAMP
);

CREATE OR REPLACE TABLE raw_customers (
    customer_id         STRING,
    customer_segment    STRING,
    region              STRING,
    join_date           DATE,
    load_timestamp      TIMESTAMP
);
