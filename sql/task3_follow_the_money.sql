-- Task 3: Follow the money
-- Dialect: SQLite. Year = SUBSTR(txn_date, 1, 4)
--   PostgreSQL: EXTRACT(YEAR FROM txn_date)   MySQL: YEAR(txn_date)

-- name: 3a_totals_by_channel
SELECT channel,
       COUNT(*)                                                      AS txns,
       SUM(amount_kes)                                               AS total_kes,
       SUM(CASE WHEN txn_type = 'DEBIT'  THEN amount_kes ELSE 0 END) AS debit_kes,
       SUM(CASE WHEN txn_type = 'CREDIT' THEN amount_kes ELSE 0 END) AS credit_kes
FROM bank_transactions
GROUP BY channel
ORDER BY total_kes DESC;

-- name: 3b_totals_by_year
SELECT SUBSTR(txn_date, 1, 4) AS yr,
       COUNT(*)               AS txns,
       SUM(amount_kes)        AS total_kes
FROM bank_transactions
GROUP BY yr
ORDER BY yr;

-- name: 3c_atm_vs_mpesa_share_of_debits
-- Share of money going out: ATM cash vs M-Pesa, per year
SELECT SUBSTR(txn_date, 1, 4) AS yr,
       ROUND(100.0 * SUM(CASE WHEN channel = 'ATM cash withdrawal' THEN amount_kes ELSE 0 END)
             / SUM(amount_kes), 1) AS atm_pct,
       ROUND(100.0 * SUM(CASE WHEN channel = 'M-Pesa' THEN amount_kes ELSE 0 END)
             / SUM(amount_kes), 1) AS mpesa_pct
FROM bank_transactions
WHERE txn_type = 'DEBIT'
GROUP BY yr
ORDER BY yr;

-- name: 3d_channels_with_over_1bn
-- HAVING example: channels that moved more than KES 1 bn in total
SELECT channel, SUM(amount_kes) AS total_kes
FROM bank_transactions
GROUP BY channel
HAVING SUM(amount_kes) > 1000000000
ORDER BY total_kes DESC;

-- name: 3e_ten_busiest_accounts
-- Joining on holder_type = 'OWNER' keeps one row per account, so joint holders
-- do not double the transaction counts.
SELECT t.account_id, COUNT(*) AS txns, SUM(t.amount_kes) AS value_kes,
       cu.full_name AS owner, co.county AS branch_county
FROM bank_transactions t
JOIN bank_account_holders h ON h.account_id = t.account_id AND h.holder_type = 'OWNER'
JOIN bank_customers cu      ON cu.customer_id = h.customer_id
JOIN bank_accounts a        ON a.account_id = t.account_id
JOIN bank_counties co       ON co.county_id = a.county_id
GROUP BY t.account_id, cu.full_name, co.county
ORDER BY txns DESC, value_kes DESC
LIMIT 10;
