#!/bin/bash
set -eu -o pipefail

cd "${SRC_DIR}"

autoconf
./configure --prefix="${PREFIX}"
make
make install
