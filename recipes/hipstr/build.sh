#!/usr/bin/env bash

set -euxo pipefail

# Fix build with modern GCC
sed -i '/#include <stdlib.h>/a #include <cstdint>' src/region.h

# Make bundled htslib find conda-provided headers and libraries
export CPATH="${PREFIX}/include:${CPATH:-}"
export LIBRARY_PATH="${PREFIX}/lib:${LIBRARY_PATH:-}"

make
install -m 755 HipSTR "${PREFIX}/bin/"