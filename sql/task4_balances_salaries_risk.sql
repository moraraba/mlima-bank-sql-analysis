-- Task 4: Balances, salaries and risk
-- Dialect: SQLite (window functions need SQLite 3.25+).

-- name: 4a_avg_current_balance_by_county
-- Current balance = balance on each account's latest transaction (ROW_NUMBER)
WITH latest AS (
    SELECT account_id, balance_kes,
           ROW_NUMBER() OVER (PARTITION BY account_id
                              ORDER BY txn_date DESC, transaction_id DESC) AS rn
    FROM bank_transactions
)
SELECT co.county, COUNT(*) AS accounts,
       ROUND(AVG(l.balance_kes)) AS avg_current_balance_kes
FROM latest l
JOIN bank_accounts a  ON a.account_id = l.account_id
JOIN bank_counties co ON co.county_id = a.county_id
WHERE l.rn = 1
GROUP BY co.county
ORDER BY avg_current_balance_kes DESC;

-- name: 4b_salary_accounts
SELECT COUNT(DISTINCT account_id) AS salary_accounts
FROM bank_transactions
WHERE purpose = 'Salary';

-- name: 4c_bad_loans_salary_vs_no_salary
-- Bad = Defaulted or In arrears
WITH sal AS (
    SELECT DISTINCT account_id FROM bank_transactions WHERE purpose = 'Salary'
)
SELECT CASE WHEN s.account_id IS NULL THEN 'No salary' ELSE 'Salary' END AS grp,
       COUNT(*) AS loans,
       SUM(CASE WHEN l.status IN ('Defaulted', 'In arrears') THEN 1 ELSE 0 END) AS bad_loans,
       ROUND(100.0 * SUM(CASE WHEN l.status IN ('Defaulted', 'In arrears') THEN 1 ELSE 0 END)
             / COUNT(*), 1) AS bad_pct
FROM bank_loans l
LEFT JOIN sal s ON s.account_id = l.account_id
GROUP BY grp
ORDER BY grp DESC;
