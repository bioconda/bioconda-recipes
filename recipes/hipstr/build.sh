#!/usr/bin/env bash

set -euxo pipefail

# Fix build with modern GCC
perl -0pi -e 's/#include <stdlib.h>/#include <stdlib.h>\n#include <cstdint>/' src/region.h

# Make bundled htslib find conda-provided headers and libraries
export CPATH="${PREFIX}/include:${CPATH:-}"
export LIBRARY_PATH="${PREFIX}/lib:${LIBRARY_PATH:-}"

# hipSTR Makefile assumes gcc exists by name
ln -s "${CC}" "${BUILD_PREFIX}/bin/gcc"

make -j${CPU_COUNT}
install -m 755 HipSTR "${PREFIX}/bin/"