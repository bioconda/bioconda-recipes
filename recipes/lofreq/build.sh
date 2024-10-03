#!/bin/bash
set -eu -o pipefail

# use newer config.guess and config.sub that support osx-arm64
cp ${RECIPE_DIR}/config.* .

./configure --with-htslib=system --prefix=${PREFIX}
make -j ${CPU_COUNT}
make install
