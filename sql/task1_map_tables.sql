-- Task 1: Map the tables
-- Dialect: SQLite. Each query starts with a "-- name:" marker used by scripts/run_queries.py.

-- name: 1a_row_counts
-- How many rows in each of the seven tables?
SELECT 'bank_counties' AS table_name, COUNT(*) AS row_count FROM bank_counties
UNION ALL SELECT 'bank_customers',       COUNT(*) FROM bank_customers
UNION ALL SELECT 'bank_accounts',        COUNT(*) FROM bank_accounts
UNION ALL SELECT 'bank_account_holders', COUNT(*) FROM bank_account_holders
UNION ALL SELECT 'bank_transactions',    COUNT(*) FROM bank_transactions
UNION ALL SELECT 'bank_loans',           COUNT(*) FROM bank_loans
UNION ALL SELECT 'bank_cards',           COUNT(*) FROM bank_cards;

-- name: 1b_cardholder_ages
-- Age of every cardholder (at end of 2024): cards -> account_holders -> customers
SELECT c.card_id, c.card_type, cu.full_name, cu.birth_year,
       2024 - cu.birth_year AS age_end_2024
FROM bank_cards c
JOIN bank_account_holders h ON h.holder_id    = c.holder_id
JOIN bank_customers cu      ON cu.customer_id = h.customer_id
ORDER BY c.card_id;

-- name: 1c_avg_age_by_card_type
-- Average cardholder age by card type
SELECT c.card_type, COUNT(*) AS cards,
       ROUND(AVG(2024 - cu.birth_year), 1) AS avg_age
FROM bank_cards c
JOIN bank_account_holders h ON h.holder_id    = c.holder_id
JOIN bank_customers cu      ON cu.customer_id = h.customer_id
GROUP BY c.card_type
ORDER BY cards DESC;
