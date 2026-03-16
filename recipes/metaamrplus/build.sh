#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${PREFIX}/bin"

# Copy executables
cp bin/metaamrplus "${PREFIX}/bin/"
cp bin/metaamrplus_batch "${PREFIX}/bin/"
cp bin/metaamrplus-download-db "${PREFIX}/bin/"

# Ensure they are executable (CRITICAL for Linux)
chmod +x "${PREFIX}/bin/metaamrplus"
chmod +x "${PREFIX}/bin/metaamrplus_batch"
chmod +x "${PREFIX}/bin/metaamrplus-download-db"

