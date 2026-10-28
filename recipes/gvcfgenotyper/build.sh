#!/bin/bash
set -eu -o pipefail

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

mkdir -p "$PREFIX/bin"

cd external/htslib-*

sed -i.bak 's|-O2|-O3|' Makefile
sed -i.bak 's|-lpthread|-pthread|g' Makefile
sed -i.bak 's|AR     = ar|#AR     = ar|' Makefile
rm -f *.bak

make CC="$CC" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" lib-static

cd ../..

sed -i.bak 's|-std=c++11 -O2|-std=c++14 -O3 -march=x86-64-v3|' Makefile
sed -i.bak 's|-O2|-O3|g' Makefile
sed -i.bak 's^-Isrc/c/^-Isrc/c/ -I$(PREFIX)/include^' Makefile
sed -i.bak 's^-lpthread^-pthread -L$(PREFIX)/lib^' Makefile
case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' Makefile
	;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' Makefile
	;;
esac
rm -f *.bak

make CC="$CC" CXX="$CXX"

install -v -m 0755 bin/gvcfgenotyper "$PREFIX/bin"
