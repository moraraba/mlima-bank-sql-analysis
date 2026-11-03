-- Task 2: Describe the customer base
-- Dialect: SQLite. Each query starts with a "-- name:" marker used by scripts/run_queries.py.

-- name: 2a_accounts_by_type_and_frequency
SELECT account_type, statement_frequency, COUNT(*) AS accounts
FROM bank_accounts
GROUP BY account_type, statement_frequency
ORDER BY account_type, statement_frequency;

-- name: 2b_customers_by_county
-- Customers by home county (most and fewest)
SELECT co.county, co.region, COUNT(*) AS customers
FROM bank_customers cu
JOIN bank_counties co ON co.county_id = cu.county_id
GROUP BY co.county, co.region
ORDER BY customers DESC;

-- name: 2c_joint_accounts
-- Accounts with more than one holder
SELECT COUNT(*) AS joint_accounts
FROM (SELECT account_id
      FROM bank_account_holders
      GROUP BY account_id
      HAVING COUNT(*) > 1) AS j;

-- name: 2d_loans_by_status
SELECT status, COUNT(*) AS loans, SUM(amount_kes) AS amount_kes
FROM bank_loans
GROUP BY status
ORDER BY loans DESC;
