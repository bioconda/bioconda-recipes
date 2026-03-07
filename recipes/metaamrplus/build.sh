#!/usr/bin/env bash
set -euo pipefail

# Ensure target bin exists
mkdir -p "${PREFIX}/bin"

# Copy executables from Bioconda files/
cp "${RECIPE_DIR}/files/metaamrplus" "${PREFIX}/bin/"
cp "${RECIPE_DIR}/files/metaamrplus_batch" "${PREFIX}/bin/"
cp "${RECIPE_DIR}/files/metaamrplus-download-db" "${PREFIX}/bin/"
cp "${RECIPE_DIR}/files/annotate_metaamrplus.py" "${PREFIX}/bin/"

# Ensure executables are runnable
chmod +x "${PREFIX}/bin/metaamrplus"
chmod +x "${PREFIX}/bin/metaamrplus_batch"
chmod +x "${PREFIX}/bin/metaamrplus-download-db"
chmod +x "${PREFIX}/bin/annotate_metaamrplus.py"

