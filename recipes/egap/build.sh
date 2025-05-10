#!/usr/bin/env bash
set -eux

# 1) Install the Python package files (your bin/ folder) into site-packages
mkdir -p "${SP_DIR}"
cp -r bin "${SP_DIR}/bin"

# 2) Install the EGAP entry-point
mkdir -p "${PREFIX}/bin"
cp EGAP.py "${PREFIX}/bin/EGAP"
chmod +x "${PREFIX}/bin/EGAP"
