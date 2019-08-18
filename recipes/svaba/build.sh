#!/bin/bash
set -eu -o pipefail

./configure CC=${CC} CFLAGS="${CFLAGS}"
make CC=${CC} CFLAGS="${CFLAGS}"
make install

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/
