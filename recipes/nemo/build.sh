#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

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

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=native|-O3 -std=c++14 -march=armv8-a -Wno-narrowing|' Makefile
	;;
    arm64)
	sed -i.bak 's|-march=native|-O3 -std=c++14 -march=armv8.4-a -Wno-narrowing|' Makefile
	;;
    x86_64)
	sed -i.bak 's|-march=native|-O3 -std=c++14 -march=x86-64-v3 -Wno-narrowing|' Makefile
	;;
esac

if [[ "$OSTYPE" == "darwin"* ]]; then
	C_OPTS="${CPPFLAGS} ${CXXFLAGS}" make GSL_PATH="$PREFIX/" CC="$CXX" SHELL="/bin/bash" MAC=1 -j"${CPU_COUNT}"
else
	C_OPTS="${CPPFLAGS} ${CXXFLAGS}" make GSL_PATH="$PREFIX/" CC="$CXX" SHELL="/bin/bash" -j"${CPU_COUNT}"
fi

make install BIN_INSTALL="$PREFIX/bin/" LIB_INSTALL="$PREFIX/lib/"
