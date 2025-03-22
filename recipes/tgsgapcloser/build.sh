#!/bin/bash

mkdir -p "${PREFIX}/bin"

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CFLAGS="$CFLAGS -O3 -L$PREFIX/lib"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export LD_FLAGS="$LD_FLAGS -L$PREFIX/lib"

make CC="${CC}" CXX="${CXX}" -j"${CPU_COUNT}"

cp -rf tgsgapcloserbin "${PREFIX}/bin"
chmod 0755 ${PREFIX}/bin/tgsgapcloserbin/*
install -v -m 0755 tgsgapcloser "${PREFIX}/bin"
