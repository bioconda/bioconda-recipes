#!/bin/bash
# post-link.sh — runs automatically after `conda install genecircuitry`.
# Installs pip-only dependencies (not available on conda-forge/bioconda).
set -euo pipefail

PYTHON_BIN="${PREFIX}/bin/python"

echo "==> [genecircuitry post-link] Installing pip-only dependencies..."
echo "    celloracle==0.18.0"
echo "    hotspotsc==1.1.3"

"${PYTHON_BIN}" -m pip install \
    --no-deps \
    --quiet \
    celloracle==0.18.0 \
    hotspotsc==1.1.3

echo "==> [genecircuitry post-link] Done."
