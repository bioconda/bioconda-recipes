#!/bin/bash

# https://bioconda.github.io/contributor/troubleshooting.html#zlib-errors
export CXXFLAGS="$CXXFLAGS -O3 -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

mkdir -p "${PREFIX}/bin"

sed -i -e 's/-static //' Makefile
sed -i.bak 's|-std=c++0x|-std=c++0x -march=x86-64-v3|' Makefile
sed -i.bak 's|$(LINK.cc)|$(CXX) $(CPPFLAGS)|' Makefile
sed -i.bak 's|-lz|-L$(PREFIX)/lib -lz|' Makefile

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' Makefile
	;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' Makefile
	;;
esac
rm -f *.bak

make

install -v -m 0755 LCA "${PREFIX}/bin"