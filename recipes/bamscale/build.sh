#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export PATH=$BUILD_PREFIX/bin:$PATH

pushd bamscale
sed -i.bak "s#gcc#${CC}#;s#g++#${CXX}#" nbproject/Makefile-Release.mk
make CC="${CC}" CXX="${CXX}" CCC="${CXX}" CFLAGS="${CFLAGS} -O3" -j"${CPU_COUNT}"
install -v -m 0755 bin/BAMscale "$PREFIX/bin"
popd
