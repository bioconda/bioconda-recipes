#!/usr/bin/env bash
set -euo pipefail

# Tarball layout (per GitHub Actions):
#   ./owl
#   ./data/GRCh38_owl_markers.bed.gz

# Install binary
install -d "${PREFIX}/bin"
install -m 0755 owl "${PREFIX}/bin/owl"

# Install marker data
install -d "${PREFIX}/share/owl/data"
install -m 0644 data/GRCh38_owl_markers.bed.gz "${PREFIX}/share/owl/data/GRCh38_owl_markers.bed.gz"