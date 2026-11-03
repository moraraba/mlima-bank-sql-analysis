-- Mlima Bank core-banking extract: table definitions (SQLite, also valid PostgreSQL)
-- Dates are stored as ISO text (YYYY-MM-DD); money is whole Kenyan shillings.

CREATE TABLE bank_counties (
    county_id              INTEGER PRIMARY KEY,
    county                 TEXT    NOT NULL,
    region                 TEXT    NOT NULL,
    population             INTEGER,
    avg_monthly_income_kes INTEGER,
    unemployment_pct       REAL,
    urban_pct              REAL
);

CREATE TABLE bank_customers (
    customer_id INTEGER PRIMARY KEY,
    full_name   TEXT    NOT NULL,
    gender      TEXT,
    birth_year  INTEGER,
    county_id   INTEGER REFERENCES bank_counties(county_id)      -- home county
);

CREATE TABLE bank_accounts (
    account_id          INTEGER PRIMARY KEY,
    county_id           INTEGER REFERENCES bank_counties(county_id), -- branch county
    opened_date         TEXT,
    account_type        TEXT,   -- Current, Savings, Business
    statement_frequency TEXT    -- Monthly, Weekly, Per transaction
);

-- Link table: one row per person on an account (many-to-many bridge)
CREATE TABLE bank_account_holders (
    holder_id   INTEGER PRIMARY KEY,
    account_id  INTEGER REFERENCES bank_accounts(account_id),
    customer_id INTEGER REFERENCES bank_customers(customer_id),
    holder_type TEXT    -- OWNER or JOINT
);

CREATE TABLE bank_transactions (
    transaction_id INTEGER PRIMARY KEY,
    account_id     INTEGER REFERENCES bank_accounts(account_id),
    txn_date       TEXT,
    txn_type       TEXT,    -- CREDIT or DEBIT
    channel        TEXT,
    purpose        TEXT,    -- blank for everyday transactions
    amount_kes     INTEGER,
    balance_kes    INTEGER
);

CREATE TABLE bank_loans (
    loan_id             INTEGER PRIMARY KEY,
    account_id          INTEGER REFERENCES bank_accounts(account_id),
    loan_date           TEXT,
    amount_kes          INTEGER,
    duration_months     INTEGER,
    monthly_payment_kes INTEGER,
    status              TEXT    -- Current, Repaid, In arrears, Defaulted
);

-- A card belongs to a holder (a person on an account), not to an account
CREATE TABLE bank_cards (
    card_id     INTEGER PRIMARY KEY,
    holder_id   INTEGER REFERENCES bank_account_holders(holder_id),
    card_type   TEXT,   -- Classic, Gold, Youth
    issued_date TEXT
);

CREATE INDEX idx_txn_account  ON bank_transactions(account_id);
CREATE INDEX idx_holder_acct  ON bank_account_holders(account_id);
CREATE INDEX idx_loans_acct   ON bank_loans(account_id);
