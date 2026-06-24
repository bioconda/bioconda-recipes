#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include"
export CFLAGS="${CFLAGS} -O3 -Wno-deprecated-declarations"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-maybe-uninitialized -Wno-unused-result -Wno-register"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	export ARCH="-march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	export ARCH="-march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	export ARCH="-march=x86-64-v3"
	;;
esac

autoreconf -if
./configure --prefix="$PREFIX" \
	--datadir="$PREFIX/share" \
	CC="${CC}" \
	CFLAGS="$CFLAGS" \
	CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	--disable-option-checking --enable-silent-rules --disable-dependency-tracking

make -j"${CPU_COUNT}"
make install

install -v -m 0755 $PREFIX/share/RNAz/perl/*.pl "$PREFIX/bin"

mkdir -p "$PREFIX/lib/perl5/site_perl"
mv $PREFIX/share/RNAz/perl/RNAz.pm $PREFIX/lib/perl5/site_perl/
