#!/bin/bash
set -euo pipefail

# configure script is not committed to git, only configure.ac -- regenerate it
autoreconf -i

./configure --prefix="${PREFIX}" PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"
make -j "${CPU_COUNT}"
make install
