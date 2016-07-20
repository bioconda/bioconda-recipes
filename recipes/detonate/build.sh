#!/bin/sh
set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

export CFLAGS_EXTRA="${LDFLAGS} ${CPPFLAGS}"
mkdir -p $PREFIX/bin


sed -e 's@INCLUDES=       -I.@INCLUDES=       -I.$(CPPFLAGS)' ref-eval/sam/Makefile

make
