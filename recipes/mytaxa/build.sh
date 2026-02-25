#!/usr/bin/env bash
set -euxo pipefail

# Build MyTaxa
make

# Install MyTaxa binaries into the conda prefix
mkdir -p "${PREFIX}/bin"

# MyTaxa builds a binary named "mytaxa"
# If this changes later, adjust this line accordingly
cp -v MyTaxa "${PREFIX}/bin/"
mkdir -p "${PREFIX}/share/mytaxa"
cp -rv utils "${PREFIX}/share/mytaxa/"

