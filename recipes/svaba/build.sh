#!/bin/bash
set -eu -o pipefail

alias gcc=${CC}

./configure
make CC=${CC} CFLAGS="${CFLAGS}"
make install

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/
