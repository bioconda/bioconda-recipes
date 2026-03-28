#!/usr/bin/env bash
set -euo pipefail

# Ensure bin directory exists
mkdir -p "${PREFIX}/bin"

# Copy executables from source package (not recipe!)
cp "${SRC_DIR}/bin/metaamrplus" "${PREFIX}/bin/"
cp "${SRC_DIR}/bin/metaamrplus_batch" "${PREFIX}/bin/"
cp "${SRC_DIR}/bin/metaamrplus-download-db" "${PREFIX}/bin/"
cp "${SRC_DIR}/bin/annotate_metaamrplus.py" "${PREFIX}/bin/"

# Make executables runnable
chmod +x "${PREFIX}/bin/metaamrplus"
chmod +x "${PREFIX}/bin/metaamrplus_batch"
chmod +x "${PREFIX}/bin/metaamrplus-download-db"
chmod +x "${PREFIX}/bin/annotate_metaamrplus.py"
