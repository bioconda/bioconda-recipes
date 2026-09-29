#!/bin/bash -e

set -euo pipefail

# We are inside the recipe build directory; conda-build will have unpacked to ./sra-tools
cd sra-tools

mkdir -p "${PREFIX}/bin"
cp -av bin/* "${PREFIX}/bin/"
mkdir -p "${PREFIX}/schema"
cp -av schema/* "${PREFIX}/schema/"
