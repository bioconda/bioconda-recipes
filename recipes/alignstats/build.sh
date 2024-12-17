#!/bin/bash
set -eu -o pipefail

cd "${SRC_DIR}"

autoconf
autoupdate
./configure --prefix="${PREFIX}" CC="${CC}"
make -j"${CPU_COUNT}"
make install
