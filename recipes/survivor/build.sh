#!/bin/bash
set -xe

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p $PREFIX/bin

sed -i.bak "s#g++#$CXX -I$PREFIX/include -L$PREFIX/lib#g" Debug/makefile

for f in Debug/src/*/subdir.mk; do
    sed -i.bak "s#g++#$CXX -I$PREFIX/include -L$PREFIX/lib#g" $f
done

sed -i.bak "s#g++#$CXX -I$PREFIX/include -L$PREFIX/lib#g" Debug/src/subdir.mk

cd Debug

make -j"${CPU_COUNT}"

install -v -m 0755 SURVIVOR "$PREFIX/bin"
