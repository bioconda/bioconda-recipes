#!/usr/bin/env bash
set -eux

# 1) Install the Python package files (your bin/ folder) into site-packages
mkdir -p "${SP_DIR}"
cp -r bin "${SP_DIR}/bin"

# 2) Install the EGAP entry-point
mkdir -p "${PREFIX}/bin"
cp EGAP.py "${PREFIX}/bin/EGAP"
chmod +x "${PREFIX}/bin/EGAP"

# 3) Install the Purge_Dups helper scripts so they’re callable
#    (they’ll find the real purge_dups executables via the conda 'purge_dups' dependency)
cp scripts/pd_config.py "${PREFIX}/bin/pd_config.py"
cp scripts/run_purge_dups.py "${PREFIX}/bin/run_purge_dups.py"
chmod +x "${PREFIX}/bin/pd_config.py" "${PREFIX}/bin/run_purge_dups.py"
