#!/bin/sh

set -euxo pipefail
echo " Setting environment variables"
# Fix zlib
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include

echo "GXX: $GXX"
echo "GCC: $GCC"
echo "----------"
make test

mkdir -p "$PREFIX"/bin

mv rtk2 "$PREFIX"/bin/
