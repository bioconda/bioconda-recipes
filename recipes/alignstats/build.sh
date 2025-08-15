#!/bin/bash
set -eu -o pipefail

export M4="${BUILD_PREFIX}/bin/m4"
cd "${SRC_DIR}"

autoconf
autoupdate
./configure --prefix="${PREFIX}" CC="${CC}"
make -j"${CPU_COUNT}"
make install
