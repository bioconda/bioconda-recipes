#!/bin/bash
set -eu -o pipefail

cd "${SRC_DIR}"

autoreconf -if
./configure --prefix="${PREFIX}" CC="${CC}"
make -j"${CPU_COUNT}"
make install
