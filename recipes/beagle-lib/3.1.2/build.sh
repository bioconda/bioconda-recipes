#!/bin/bash

set -xe

export M4="${BUILD_PREFIX}/bin/m4"
export INCLUDES="-I{PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

case $(uname -m) in
	aarch64 | arm64)
		ARCH_OPTS="--disable-sse"
		;;
	*)
		ARCH_OPTS=""
		;;
esac

./autogen.sh
./configure CC="${CC}" CXX="${CXX}" --prefix=${PREFIX} --with-jdk=${PREFIX} --disable-march-native ${ARCH_OPTS}
make -j ${CPU_COUNT}
make install
