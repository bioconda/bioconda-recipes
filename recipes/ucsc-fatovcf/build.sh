#!/bin/bash

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include
export USE_HIC=0

mkdir -p "$PREFIX/bin"
export MACHTYPE=x86_64
export BINDIR=$(pwd)/bin
export L="${LDFLAGS}"
mkdir -p "$BINDIR"
patch kent/src/inc/common.mk $RECIPE_DIR/inc.common.mk.v426.patch
(cd kent/src/lib && make)
(cd kent/src/htslib && make)
(cd kent/src/jkOwnLib && make)
(cd kent/src/hg/lib && make)
(cd kent/src/hg/utils/faToVcf && make)
cp bin/faToVcf "$PREFIX/bin"
chmod +x "$PREFIX/bin/faToVcf"
