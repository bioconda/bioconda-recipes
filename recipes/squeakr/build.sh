#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"
export ARCH="$(uname -m)"

install -d $PREFIX/bin

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

sed -i.bak 's|-lpthread|-pthread|' Makefile
if [[ "$(uname -s)" == "Darwin" ]]; then
	sed -i.bak 's|-lrt||' Makefile
fi

if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
	sed -i.bak 's|-m64||' Makefile
	sed -i.bak 's|-msse4.2 -D__SSE4_2_||' Makefile
fi

if [[ "$(uname -m)" == "aarch64" ]]; then
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' Makefile
elif [[ "$(uname -m)" == "arm64" ]]; then
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' Makefile
fi
rm -f *.bak

make CC="${CC} -std=gnu11" LD="${CXX} -std=c++14" CXX="${CXX} -std=c++14" \
   CXXFLAGS="${CXXFLAGS} -I. -I${SRC_DIR}/include" \
   CFLAGS="${CFLAGS} -I. -I${SRC_DIR}/include" \
   ARCH="${ARCH}" -j"${CPU_COUNT}"

install -v -m 0755 squeakr "$PREFIX/bin"
