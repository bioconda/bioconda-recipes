#!/bin/bash
set -eu -o pipefail

./configure --with-htslib=system --prefix=${PREFIX}
make
make install
