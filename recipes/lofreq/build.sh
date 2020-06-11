#!/bin/bash
set -eu -o pipefail

./configure --help
ls -l ${PREFIX}/lib
./configure --with-htslib=${PREFIX}/lib  --prefix=${PREFIX} --enable-debug
make
make install
