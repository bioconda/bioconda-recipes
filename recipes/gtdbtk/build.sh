#!/bin/bash

# Configuration
TARGET="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
GTDBTK_DATA_PATH="${TARGET}/db"
DOWNLOAD_SCRIPT_BIN="${PREFIX}/bin/download-db.sh"

# Install python libraries
python -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv

# Create folder for database download
mkdir -p "$GTDBTK_DATA_PATH"
touch "${GTDBTK_DATA_PATH}/.empty"

# Copy script to download database
mkdir -p "${PREFIX}/bin"
echo '#!/usr/bin/env bash' > "$DOWNLOAD_SCRIPT_BIN"
echo "export GTDBTK_DATA_PATH=\"${GTDBTK_DATA_PATH}\"" >> "$DOWNLOAD_SCRIPT_BIN"
cat "${RECIPE_DIR}/download-db.sh" >> "$DOWNLOAD_SCRIPT_BIN"
chmod +x "$DOWNLOAD_SCRIPT_BIN"
