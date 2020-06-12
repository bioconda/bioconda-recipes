#!/bin/bash
set -eu -o pipefail

./configure --with-htslib=${PREFIX}/lib  --prefix=${PREFIX} --enable-debug

make
make install
