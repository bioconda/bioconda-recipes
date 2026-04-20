#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14 -Wno-array-bounds -Wno-narrowing -Wno-deprecated-declarations -Wno-double-promotion"
export CFLAGS="${CFLAGS} -O3"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* m4/

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

sed -i.bak 's|2.3.0rc1|2.4.0|' configure.ac
sed -i.bak 's|2.3.0rc1|2.4.0|' configure
rm -f *.bak
sed -i.bak 's|2.3.0rc4|2.4.0|' cosi/cositop.cc
rm -f cosi/*.bak

autoreconf -if
./configure --prefix="${PREFIX}" \
	--disable-option-checking --enable-silent-rules \
	--disable-dependency-tracking \
	CC="${CC}" CFLAGS="${CFLAGS}" \
	CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}"

make
make install
