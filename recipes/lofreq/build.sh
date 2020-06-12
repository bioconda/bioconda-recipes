#!/bin/bash
set -eu -o pipefail

./configure --with-htslib=${PREFIX}/lib  --prefix=${PREFIX}

make
make install
