#!/bin/bash
set -eu -o pipefail

./configure CC=${CC} CFLAGS="${CFLAGS}"
make
make install

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/
