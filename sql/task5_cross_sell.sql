-- Task 5: Find the cross-sell targets
-- Dialect: SQLite. A card belongs to a holder, so it is mapped back to the
-- account through account_holders before checking "has a card".

-- name: 5a_top_decile_card_loan_gaps
WITH val AS (
    SELECT account_id, SUM(amount_kes) AS total_value
    FROM bank_transactions GROUP BY account_id
), ranked AS (
    SELECT v.*, NTILE(10) OVER (ORDER BY total_value DESC) AS decile FROM val v
), carded AS (
    SELECT DISTINCT h.account_id FROM bank_cards c JOIN bank_account_holders h ON h.holder_id = c.holder_id
), loaned AS (
    SELECT DISTINCT account_id FROM bank_loans
)
SELECT COUNT(*) AS top_decile_accounts,
       MIN(total_value) AS min_value_kes,
       SUM(CASE WHEN account_id NOT IN (SELECT account_id FROM carded) THEN 1 ELSE 0 END) AS no_card,
       SUM(CASE WHEN account_id NOT IN (SELECT account_id FROM loaned) THEN 1 ELSE 0 END) AS no_loan,
       SUM(CASE WHEN account_id NOT IN (SELECT account_id FROM carded)
                 AND account_id NOT IN (SELECT account_id FROM loaned) THEN 1 ELSE 0 END) AS neither
FROM ranked
WHERE decile = 1;

-- name: 5b_card_loan_penetration_by_decile
WITH val AS (
    SELECT account_id, SUM(amount_kes) AS total_value
    FROM bank_transactions GROUP BY account_id
), ranked AS (
    SELECT v.*, NTILE(10) OVER (ORDER BY total_value DESC) AS decile FROM val v
), carded AS (
    SELECT DISTINCT h.account_id FROM bank_cards c JOIN bank_account_holders h ON h.holder_id = c.holder_id
)
SELECT decile, COUNT(*) AS accounts, ROUND(AVG(total_value)) AS avg_value_kes,
       ROUND(100.0 * AVG(CASE WHEN account_id IN (SELECT account_id FROM carded) THEN 1 ELSE 0 END), 1) AS card_pct,
       ROUND(100.0 * AVG(CASE WHEN account_id IN (SELECT account_id FROM bank_loans)  THEN 1 ELSE 0 END), 1) AS loan_pct
FROM ranked
GROUP BY decile
ORDER BY decile;

-- name: 5c_target_list_no_card_no_loan
-- Named list: top-decile accounts with neither a card nor a loan
WITH val AS (
    SELECT account_id, SUM(amount_kes) AS total_value, COUNT(*) AS txns
    FROM bank_transactions GROUP BY account_id
), ranked AS (
    SELECT v.*, NTILE(10) OVER (ORDER BY total_value DESC) AS decile FROM val v
), carded AS (
    SELECT DISTINCT h.account_id FROM bank_cards c JOIN bank_account_holders h ON h.holder_id = c.holder_id
)
SELECT r.account_id, a.account_type, co.county AS branch_county,
       cu.full_name AS owner, r.total_value AS total_value_kes, r.txns,
       CASE WHEN r.account_id IN (SELECT account_id FROM bank_transactions WHERE purpose = 'Salary')
            THEN 'Yes' ELSE 'No' END AS salary_paid_in
FROM ranked r
JOIN bank_accounts a        ON a.account_id = r.account_id
JOIN bank_counties co       ON co.county_id = a.county_id
JOIN bank_account_holders h ON h.account_id = r.account_id AND h.holder_type = 'OWNER'
JOIN bank_customers cu      ON cu.customer_id = h.customer_id
WHERE r.decile = 1
  AND r.account_id NOT IN (SELECT account_id FROM carded)
  AND r.account_id NOT IN (SELECT account_id FROM bank_loans)
ORDER BY r.total_value DESC;

-- name: 5d_targets_by_county
WITH val AS (
    SELECT account_id, SUM(amount_kes) AS total_value FROM bank_transactions GROUP BY account_id
), ranked AS (
    SELECT v.*, NTILE(10) OVER (ORDER BY total_value DESC) AS decile FROM val v
), carded AS (
    SELECT DISTINCT h.account_id FROM bank_cards c JOIN bank_account_holders h ON h.holder_id = c.holder_id
)
SELECT co.county, COUNT(*) AS targets
FROM ranked r
JOIN bank_accounts a  ON a.account_id = r.account_id
JOIN bank_counties co ON co.county_id = a.county_id
WHERE r.decile = 1
  AND r.account_id NOT IN (SELECT account_id FROM carded)
  AND r.account_id NOT IN (SELECT account_id FROM bank_loans)
GROUP BY co.county
ORDER BY targets DESC, co.county;

-- name: 5e_top_decile_no_card_atm_2024
-- Cash that busy, card-less customers still take out at the ATM
WITH val AS (
    SELECT account_id, SUM(amount_kes) AS total_value FROM bank_transactions GROUP BY account_id
), ranked AS (
    SELECT v.*, NTILE(10) OVER (ORDER BY total_value DESC) AS decile FROM val v
), carded AS (
    SELECT DISTINCT h.account_id FROM bank_cards c JOIN bank_account_holders h ON h.holder_id = c.holder_id
)
SELECT COUNT(DISTINCT t.account_id) AS accounts,
       COUNT(*)                     AS atm_withdrawals,
       SUM(t.amount_kes)            AS atm_value_kes
FROM bank_transactions t
JOIN ranked r ON r.account_id = t.account_id
WHERE r.decile = 1
  AND t.account_id NOT IN (SELECT account_id FROM carded)
  AND t.channel = 'ATM cash withdrawal'
  AND t.txn_date >= '2024-01-01' AND t.txn_date < '2025-01-01';

-- name: 5f_salary_accounts_without_loan
WITH sal AS (SELECT DISTINCT account_id FROM bank_transactions WHERE purpose = 'Salary')
SELECT COUNT(*) AS salary_accounts,
       SUM(CASE WHEN account_id NOT IN (SELECT account_id FROM bank_loans) THEN 1 ELSE 0 END) AS without_loan
FROM sal;

-- name: 5g_mpesa_withdrawals_2024_lag
WITH m AS (
    SELECT SUBSTR(txn_date, 1, 7) AS month, COUNT(*) AS txns, SUM(amount_kes) AS value_kes
    FROM bank_transactions
    WHERE channel = 'M-Pesa' AND txn_type = 'DEBIT'
      AND txn_date >= '2024-01-01' AND txn_date < '2025-01-01'
    GROUP BY month
)
SELECT month, txns, value_kes,
       value_kes - LAG(value_kes) OVER (ORDER BY month) AS change_kes,
       ROUND(100.0 * (value_kes - LAG(value_kes) OVER (ORDER BY month))
             / LAG(value_kes) OVER (ORDER BY month), 1) AS change_pct
FROM m
ORDER BY month;
