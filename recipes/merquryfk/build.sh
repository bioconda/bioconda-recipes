#!/bin/bash

set -xe

mkdir -p "${PREFIX}/bin"

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CFLAGS="${CFLAGS} -O3"
export CPATH="${PREFIX}/include"

make -j"${CPU_COUNT}"

install -v -m 0755 HAPmaker ASMplot CNplot HAPplot MerquryFK KatComp KatGC "${PREFIX}/bin"
