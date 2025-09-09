#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export CFLAGS="${CFLAGS} -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

mkdir -p "$PREFIX/bin"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* lib/htslib

#Inject compilers
sed -i.bak "s#gcc#${CC}#g" lib/pcre2/Makefile
rm -f lib/pcre2/*.bak

make CXX="${CXX}" CC="${CC}" OPTFLAG="-O3 -I${PREFIX}/include -L${PREFIX}/lib" -j"${CPU_COUNT}"
make test

install -v -m 0755 vt "$PREFIX/bin"
