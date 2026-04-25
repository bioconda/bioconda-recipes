#!/bin/bash
set -eu

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-unused-variable -Wno-template-id-cdtor -Wno-unknown-warning-option"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -lstdc++fs"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-unused-but-set-variable"
export CFLAGS="${CFLAGS} -O3"

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

case $(uname -s) in
    Darwin)
	export CXXFLAGS="${CXXFLAGS} -std=c++20" ;;
	Linux)
	export CXXFLAGS="${CXXFLAGS} -std=c++14" ;;
esac

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

autoreconf -if
./configure --prefix="${PREFIX}" CXX="${CXX}" CC="${CC}" \
	LDFLAGS="${LDFLAGS}" CPPFLAGS="${CPPFLAGS}" \
	CXXFLAGS="${CXXFLAGS}" CFLAGS="${CFLAGS}" \
	--with-snappy --with-io_lib \
	--with-libsecrecy --with-nettle \
	--with-lzma --with-gmp --with-parasail \
	--enable-shared-libmaus2 --disable-option-checking \
	--disable-dependency-tracking --enable-silent-rules

make clean

make -j"${CPU_COUNT}"
make install
