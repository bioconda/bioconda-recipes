#!/bin/bash
set -eu -o pipefail

./configure --with-htslib=system --prefix=${PREFIX}
make -j ${CPU_COUNT}
make install
