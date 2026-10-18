#!/bin/bash
set -xe

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/include

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Patch v1.2.8 makefile; remove in next release
sed -i.orig -e 's/-L/${LDFLAGS} -L/' src/Makefile

make LIBS="-lwiggletools -lBigWig -lgsl -lgslcblas -lhts -pthread -lm" -j"${CPU_COUNT}"

cp -f lib/libwiggletools.a $PREFIX/lib/
cp -f inc/wiggletools.h $PREFIX/include/
install -v -m 755 bin/wiggletools "$PREFIX/bin"
