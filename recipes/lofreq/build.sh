#!/bin/bash
set -eu -o pipefail

CFLAGS="${CFLAGS} -Og -pedantic"
CXXFLAGS="${CXXFLAGS} -Og -pedantic"

./configure --with-htslib=${PREFIX}/lib  --prefix=${PREFIX}

make
make install
