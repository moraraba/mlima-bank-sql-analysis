#!/usr/bin/env bash
# Rebuild the database, run every query and redraw the charts.
set -euo pipefail
cd "$(dirname "$0")"
python3 scripts/build_db.py
python3 scripts/run_queries.py
python3 scripts/make_charts.py
echo "Done. See results/RESULTS.md and charts/."
