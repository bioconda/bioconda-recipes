#!/usr/bin/env bash
set -xe

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -I$PREFIX/include/bamtools"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"

mkdir -p "$PREFIX/bin"

sed -i.bak "s#gcc#${CC}#;s#g++#${CXX}#" nbproject/Makefile-Release.mk
rm -f nbproject/*.bak

make -j"${CPU_COUNT}"
install -v -m 0755 bin/TPMCalculator "$PREFIX/bin"
