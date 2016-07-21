#!/bin/sh
set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib "
export CPPFLAGS="-I${PREFIX}/include -I${PREFIX}/include/ncursesw/"
export CFLAGS="$CPPFLAGS"

export CFLAGS_EXTRA="${LDFLAGS} ${CPPFLAGS}"
mkdir -p $PREFIX/bin

find -name Makefile | xargs -I {} sed -i.bak 's/-lcurses/-lncurses/g' {}

make
