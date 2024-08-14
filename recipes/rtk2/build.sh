#!/bin/bash
set -euxo pipefail

mkdir -p "$PREFIX"/bin

echo "Setting environment variables"
# Fix zlib
export CFLAGS="$CFLAGS -O3 -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export C_INCLUDE_PATH=${PREFIX}/include

echo "RUN MAKE"
make test

chmod 755 rtk2
mv rtk2 "$PREFIX"/bin/
