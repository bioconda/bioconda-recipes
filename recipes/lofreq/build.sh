#!/bin/bash
set -eu -o pipefail

CFLAGS="${CFLAGS} -Og -g -pedantic"

./configure --with-htslib=${PREFIX}/lib  --prefix=${PREFIX}

make
make install
