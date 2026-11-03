# Mlima Bank – Cross-sell Recommendations

**To:** Head of Retail Banking · **From:** Retail Banking Insights · **Data:** core-banking extract, Jan 2021 – Dec 2024 (KES)

Our busiest customers are the least served: **66 of the 90 highest-value accounts have no card**, and **48 have neither a card nor a loan**. Salaried customers repay far better (**6.3% bad loans vs 26.1%**). Next year's budget should therefore go first to cards for the top 10% and loans for salary earners, concentrated in Nairobi and Kiambu.

## Three recommendations

| # | Who to target | What to offer | Figure behind it (query) |
|---|---|---|---|
| 1 | **Top 10% of accounts by value with no card** (66 accounts, each moving over KES 10.3 m since 2021) | Classic or Gold debit card, pre-approved, issued at branch | 66 of 90 top-decile accounts have no card (73%). In 2024 alone they made **282 ATM withdrawals worth KES 34.1 m** that a card could move to POS. Card POS is used only by card holders: all 4,274 POS payments come from the 227 carded accounts. *(5a, 5e)* |
| 2 | **Salary accounts with no loan** (221 of 379 salary accounts) | Salary-backed personal loan, repaid by standing order on payday | Loans on salary accounts go bad at **6.3% (10 of 158)** against **26.1% (36 of 138)** without a salary, four times lower risk. *(4c, 5f)* |
| 3 | **The 48 top-decile accounts with neither a card nor a loan**, starting in Nairobi (23) and Kiambu (8) | Relationship-manager call offering a card + loan bundle; the 15 Business-account owners get a business card | Nairobi and Kiambu also hold the highest average current balances: **KES 1.43 m and 1.02 m**, against KES 0.37–0.56 m in most other counties. All 48 owners are named in `results/5c_target_list_no_card_no_loan.csv`. *(4a, 5c, 5d)* |

**Sequence:** run 1 and 3 together in Q1, since they target overlapping customers. Then roll out 2 to the remaining salary accounts.

## Supporting facts

| Question | Answer |
|---|---|
| Size of the book | 900 accounts, 1,034 customers (134 joint accounts), 296 loans, 232 cards, 102,880 transactions |
| Loan book | 176 Current, 74 Repaid, 27 In arrears, 19 Defaulted |
| Channel moving most money | M-Pesa: KES 2.22 bn across 40,292 transactions |
| ATM cash share of debit value | 61.0% in 2021, down to 24.1% in 2024; M-Pesa rose from 31.7% to 60.2% |
| Busiest account | 2108: 286 transactions, owner Wanjiru Hassan (Nairobi) |
| Biggest 2024 M-Pesa jump | December: +KES 8.9 m (+22.9%) to KES 47.9 m, likely festive spending and travel upcountry |

Card and loan status is counted per account. A card belongs to a holder, so it is linked back to the account through `bank_account_holders`. Owner-only joins stop joint holders being counted twice. The data is a synthetic extract.
