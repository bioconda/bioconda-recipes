#!/bin/bash
set -euo pipefail

cd ./source
mkdir -p $PREFIX/bin
make CC="$CC -fcommon $CFLAGS $LDFLAGS" CPPFLAGS="$CPPFLAGS"
mv dialign-tx $PREFIX/bin/
