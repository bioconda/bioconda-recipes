#!/bin/bash -e

set -euo pipefail

# We are inside the recipe build directory; conda-build will have unpacked to ./sra-tools
cd sra-tools

mkdir -p "${PREFIX}/bin"
cp -av bin/* "${PREFIX}/bin/"

# Install schema files (location may matter; pick one and ensure tools can find it)
mkdir -p "${PREFIX}/share/sra-tools"
cp -av schema "${PREFIX}/share/sra-tools/"