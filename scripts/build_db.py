"""Build mlima_bank.db (SQLite) from sql/schema.sql and the CSV files in data/."""
import csv
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DB = ROOT / "mlima_bank.db"

# Each CSV loads into a table named after its file: bank-customers.csv -> bank_customers
TABLES = {
    "bank_counties": "bank-counties.csv",
    "bank_customers": "bank-customers.csv",
    "bank_accounts": "bank-accounts.csv",
    "bank_account_holders": "bank-account-holders.csv",
    "bank_transactions": "bank-transactions.csv",
    "bank_loans": "bank-loans.csv",
    "bank_cards": "bank-cards.csv",
}


def convert(value):
    if value == "":
        return None
    for cast in (int, float):
        try:
            return cast(value)
        except ValueError:
            pass
    return value


def main():
    DB.unlink(missing_ok=True)
    con = sqlite3.connect(DB)
    con.executescript((ROOT / "sql" / "schema.sql").read_text())
    for table, filename in TABLES.items():
        with open(ROOT / "data" / filename, newline="", encoding="utf-8") as f:
            reader = csv.reader(f)
            header = next(reader)
            rows = [[convert(v) for v in row] for row in reader]
        placeholders = ",".join("?" * len(header))
        con.executemany(
            f"INSERT INTO {table} ({','.join(header)}) VALUES ({placeholders})", rows
        )
        print(f"{table:<22} {len(rows):>7,} rows")
    con.commit()
    con.close()
    print(f"Built {DB.name}")


if __name__ == "__main__":
    main()
