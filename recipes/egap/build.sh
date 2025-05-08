#!/bin/bash
set -eux

# Install the bin/ package into site-packages
mkdir -p "${SP_DIR}"
cp -r bin "${SP_DIR}/bin"

# Install just one entry-point script
mkdir -p "${PREFIX}/bin"
cp EGAP.py "${PREFIX}/bin/EGAP"
chmod +x "${PREFIX}/bin/EGAP"