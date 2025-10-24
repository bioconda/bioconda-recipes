#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

./src/Parasail/build

install -v -m 0755 src/ESPRESSO_C.pl \
	src/ESPRESSO_Q.pl src/ESPRESSO_Q_Thread.pm \
	src/ESPRESSO_S.pl src/ESPRESSO_Version.pm \
	src/Parasail.pm src/Parasail.so "${PREFIX}/bin"

cp -f src/libparasail.* $PREFIX/lib/
