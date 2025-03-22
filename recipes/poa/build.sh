#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

make poa CC="$CC" CXX="$CXX" \
	CFLAGS="$CFLAGS -O3 -Wno-implicit-function-declaration -Wno-format -fcommon -DUSE_WEIGHTED_LINKS -DUSE_PROJECT_HEADER -I." \
	-j"${CPU_COUNT}"

install -v -m 0755 poa $PREFIX/bin
install -v -m 0755 make_pscores.pl $PREFIX/bin
cp -rf liblpo.a $PREFIX/lib
