#!/bin/sh

set -euxo pipefail
mkdir -p "$PREFIX"/bin

echo " Setting environment variables"
# Fix zlib
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include

echo "RUN MAKE"
make test

mv rtk2 "$PREFIX"/bin/
