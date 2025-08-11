#!/bin/bash

mkdir -p "$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM" "$PREFIX/bin"

export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++0x -Wall -fopenmp -DGZSTREAM_NAMESPACE=gz -g -I."
export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib -L. -lkraken -lz"
export CPATH="${PREFIX}/include"

sed -i.bak 's|CXX =|#CXX =|' src/Makefile
sed -i.bak 's|AR       =|#AR       =|' src/Makefile
sed -i.bak 's|${AR}|$(AR) rcs|' src/Makefile
rm -rf src/*.bak

if [[ `uname -s` == "Darwin" ]]; then
	ln -sf ${CC} ${PREFIX}/bin/clang
	ln -sf ${CXX} ${PREFIX}/bin/clang++
else
	ln -sf ${CC} ${PREFIX}/bin/gcc
	ln -sf ${CXX} ${PREFIX}/bin/g++
fi

chmod u+x install_kraken_conda.sh

./install_kraken_conda.sh "$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
for bin in kraken kraken-build kraken-filter kraken-mpa-report kraken-report kraken-translate; do
    sed -i.bak 's|#!/usr/bin/perl|#!/usr/bin/env perl|' $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/$bin
    rm -f $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/$bin.bak
    chmod +x "$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/$bin"
    ln -s "$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/$bin" "$PREFIX/bin/$bin"
done

if [[ `uname -s` == "Darwin" ]]; then
	rm -rf ${PREFIX}/bin/clang
	rm -rf ${PREFIX}/bin/clang++
else
	rm -rf ${PREFIX}/bin/gcc
	rm -rf ${PREFIX}/bin/g++
fi
