#!/usr/bin/env bash
set -eux

# Install the EGAP entry-point
mkdir -p "${PREFIX}/bin"
cp -r bin/* "${PREFIX}/bin/"
cp EGAP.py "${PREFIX}/bin/EGAP"
chmod +x "${PREFIX}/bin/EGAP"
