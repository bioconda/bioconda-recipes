#!/bin/bash
set -euo pipefail

cd ./source

# fix source code: remove "inline" from structs
#sed -i.bak -e 's/inline//g' *.c

mkdir -p $PREFIX/bin
make CC="$CC $CFLAGS $LDFLAGS" CPPFLAGS="$CPPFLAGS"
mv dialign-tx $PREFIX/bin/
