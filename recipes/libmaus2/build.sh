#!/bin/bash
set -eu

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-unused-variable -Wno-unused-but-set-variable"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-unused-variable -Wno-unused-but-set-variable"
export CFLAGS="${CFLAGS} -O3"
export LIBS="-lstdc++fs -lcurl -lz -ldeflate"

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

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

autoreconf -if
./configure --prefix="${PREFIX}" CXX="${CXX}" CC="${CC}" \
	LDFLAGS="${LDFLAGS}" CPPFLAGS="${CPPFLAGS}" \
	CXXFLAGS="${CXXFLAGS}" CFLAGS="${CFLAGS}" \
	--with-snappy --with-io_lib --with-libdeflate \
	--with-libsecrecy --with-nettle \
	--with-lzma --with-gmp \
	--disable-option-checking --enable-silent-rules --disable-dependency-tracking

make clean

make -j"${CPU_COUNT}"
make install
