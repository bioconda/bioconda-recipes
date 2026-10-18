#!/bin/bash

# https://bioconda.github.io/contributor/troubleshooting.html#zlib-errors
export CXXFLAGS="$CXXFLAGS -O3 -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

mkdir -p "${PREFIX}/bin"

sed -i -e 's/-static //' Makefile
sed -i.bak 's|$(LINK.cc)|$(CXX) $(CPPFLAGS)|' Makefile
sed -i.bak 's|-lz|-L$(PREFIX)/lib -lz|' Makefile
sed -i.bak 's|-lpthread|-pthread|g' Makefile

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-std=c++0x|-std=c++0x -march=armv8-a|' Makefile
	;;
    arm64)
	sed -i.bak 's|-std=c++0x|-std=c++0x -march=armv8.4-a|' Makefile
	;;
esac

case $(uname -s) in
    Darwin)
        sed -i.bak 's|-Wl,--whole-archive||' Makefile
		sed -i.bak 's|-Wl,--no-whole-archive||' Makefile
        ;;
esac

rm -f *.bak

make -j"${CPU_COUNT}"

install -v -m 0755 LCA "${PREFIX}/bin"
