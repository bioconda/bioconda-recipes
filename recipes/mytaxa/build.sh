#!/usr/bin/env bash
set -euxo pipefail

# Build MyTaxa
make CC="${CXX:-c++}"

# Install MyTaxa binaries into the conda prefix
mkdir -p "${PREFIX}/bin"
cp -v MyTaxa "${PREFIX}/bin/"

# Install utils
mkdir -p "${PREFIX}/share/mytaxa"
cp -rv utils "${PREFIX}/share/mytaxa/"

