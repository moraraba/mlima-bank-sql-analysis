"""Draw the report charts from the CSVs in results/ (run run_queries.py first)."""
import csv
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parent.parent
RES = ROOT / "results"
OUT = ROOT / "charts"

BLUE, ORANGE, GREY, RED, INK = "#1f4e79", "#d9822b", "#b8c2cc", "#c0392b", "#1a2733"

plt.rcParams.update({
    "font.family": "DejaVu Sans", "font.size": 11, "axes.spines.top": False,
    "axes.spines.right": False, "axes.edgecolor": "#8a96a3", "axes.titleweight": "bold",
    "axes.titlesize": 13, "axes.titlelocation": "left", "figure.dpi": 150,
})


def read(name):
    with open(RES / f"{name}.csv", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def save(fig, name):
    fig.tight_layout()
    fig.savefig(OUT / name, bbox_inches="tight", facecolor="white")
    plt.close(fig)
    print("wrote charts/" + name)


def atm_vs_mpesa():
    rows = read("3c_atm_vs_mpesa_share_of_debits")
    yrs = [r["yr"] for r in rows]
    atm = [float(r["atm_pct"]) for r in rows]
    mp = [float(r["mpesa_pct"]) for r in rows]
    fig, ax = plt.subplots(figsize=(7.5, 4.2))
    ax.plot(yrs, mp, marker="o", lw=2.5, color=BLUE)
    ax.plot(yrs, atm, marker="o", lw=2.5, color=ORANGE)
    for x, a, m in zip(yrs, atm, mp):
        up, down = (8, -16)
        ax.annotate(f"{m:.0f}%", (x, m), textcoords="offset points",
                    xytext=(0, up if m > a else down), ha="center", color=BLUE)
        ax.annotate(f"{a:.0f}%", (x, a), textcoords="offset points",
                    xytext=(0, up if a > m else down), ha="center", color=ORANGE)
    ax.text(yrs[-1], mp[-1] + 6, "M-Pesa", color=BLUE, ha="center", fontweight="bold")
    ax.text(yrs[-1], atm[-1] - 10, "ATM cash", color=ORANGE, ha="center", fontweight="bold")
    ax.set_ylim(0, 75)
    ax.set_ylabel("Share of debit value (%)")
    ax.set_title("Cash is giving way to M-Pesa: ATM share of money out fell from 61% to 24%")
    ax.grid(axis="y", color="#e5e9ee")
    save(fig, "atm_vs_mpesa_share.png")


def bad_loans():
    rows = {r["grp"]: r for r in read("4c_bad_loans_salary_vs_no_salary")}
    groups = ["Salary", "No salary"]
    pct = [float(rows[g]["bad_pct"]) for g in groups]
    fig, ax = plt.subplots(figsize=(6.5, 3.4))
    bars = ax.barh(groups, pct, color=[BLUE, RED], height=0.55)
    for b, g, p in zip(bars, groups, pct):
        ax.text(p + 0.6, b.get_y() + b.get_height() / 2,
                f"{p:.1f}%  ({rows[g]['bad_loans']} of {rows[g]['loans']} loans)", va="center")
    ax.set_xlim(0, 36)
    ax.invert_yaxis()
    ax.set_xlabel("Loans Defaulted or In arrears (%)")
    ax.set_title("Salary accounts repay far better: 6.3% bad vs 26.1%")
    save(fig, "bad_loans_salary_vs_no_salary.png")


def mpesa_2024():
    rows = read("5g_mpesa_withdrawals_2024_lag")
    months = [r["month"][5:] for r in rows]
    labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    vals = [int(r["value_kes"]) / 1e6 for r in rows]
    chg = [float(r["change_pct"]) if r["change_pct"] else 0.0 for r in rows]
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(8, 5.4), sharex=True,
                                   gridspec_kw={"height_ratios": [2, 1.2]})
    ax1.plot(labels[: len(months)], vals, marker="o", lw=2.5, color=BLUE)
    ax1.annotate(f"KES {vals[-1]:.1f} m", (labels[11], vals[-1]), textcoords="offset points",
                 xytext=(-10, -4), ha="right", color=BLUE, fontweight="bold")
    ax1.set_ylabel("KES millions")
    ax1.set_ylim(30, 50)
    ax1.grid(axis="y", color="#e5e9ee")
    ax1.set_title("M-Pesa withdrawals 2024: December jumped 22.9% (KES +8.9 m)")
    colors = [RED if c == max(chg) else (BLUE if c >= 0 else GREY) for c in chg]
    ax2.bar(labels[: len(months)], chg, color=colors)
    ax2.axhline(0, color="#8a96a3", lw=1)
    ax2.set_ylabel("Change vs prior\nmonth (%)")
    for x, c in zip(labels, chg):
        if c:
            ax2.text(x, c + (1 if c > 0 else -3.5), f"{c:+.0f}", ha="center", fontsize=9)
    ax2.set_ylim(-8, 28)
    save(fig, "mpesa_2024_monthly_lag.png")


def top_decile_gaps():
    r = read("5a_top_decile_card_loan_gaps")[0]
    total, no_card, no_loan, neither = (int(r[k]) for k in
                                        ("top_decile_accounts", "no_card", "no_loan", "neither"))
    has_both = total - no_card - no_loan + neither
    card_only = no_loan - neither
    loan_only = no_card - neither
    parts = [("Neither card nor loan", neither, RED), ("Loan, no card", loan_only, ORANGE),
             ("Card, no loan", card_only, GREY), ("Card and loan", has_both, BLUE)]
    fig, ax = plt.subplots(figsize=(8.5, 2.6))
    left = 0
    for label, n, c in parts:
        ax.barh([0], [n], left=left, color=c, height=0.6)
        ax.text(left + n / 2, 0, str(n), ha="center", va="center", color="white", fontweight="bold")
        ax.text(left + n / 2, 0.48, label, ha="center", va="bottom", fontsize=9, color=INK)
        left += n
    ax.set_xlim(0, total)
    ax.set_ylim(-0.5, 0.95)
    ax.set_yticks([])
    ax.set_xlabel(f"The {total} busiest accounts (top 10% by transaction value)")
    ax.set_title(f"{no_card} of the {total} busiest accounts have no card; {neither} have neither product")
    ax.spines["left"].set_visible(False)
    save(fig, "top_decile_card_loan_gaps.png")


def balance_by_county():
    rows = read("4a_avg_current_balance_by_county")
    names = [r["county"] for r in rows][::-1]
    vals = [float(r["avg_current_balance_kes"]) / 1e6 for r in rows][::-1]
    fig, ax = plt.subplots(figsize=(7, 5.2))
    colors = [BLUE if i >= len(vals) - 3 else GREY for i in range(len(vals))]
    ax.barh(names, vals, color=colors)
    for i, v in enumerate(vals):
        ax.text(v + 0.02, i, f"{v:.2f}", va="center", fontsize=9)
    ax.set_xlabel("Average current balance (KES millions)")
    ax.set_title("Nairobi, Kiambu and Kajiado hold the richest accounts")
    ax.set_xlim(0, 1.65)
    save(fig, "avg_balance_by_county.png")


if __name__ == "__main__":
    OUT.mkdir(exist_ok=True)
    atm_vs_mpesa()
    bad_loans()
    mpesa_2024()
    top_decile_gaps()
    balance_by_county()
