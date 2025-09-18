#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"
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

mkdir -p "$PREFIX/bin"
mkdir -p build-aux

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* build-aux/

sed -i.bak 's|-m64||' configure.ac
rm -f *.bak

autoreconf -if
./configure --prefix="${PREFIX}" \
	--with-boost="${PREFIX}" \
	--with-zlib="${PREFIX}" \
	--with-eigen="${PREFIX}" \
	--disable-option-checking \
	--enable-dependency-tracking \
	--enable-silent-rules \
	CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS}" \
	CC="${CC}" \
	CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}"

make -j"${CPU_COUNT}"
make install

if [[ $PY3K -eq 1 ]]; then
	2to3 --write ${PREFIX}/bin/cuffmerge
fi

#cp cufflinks $PREFIX/bin
#cp cuffcompare $PREFIX/bin
#cp cuffdiff $PREFIX/bin
#cp cuffmerge $PREFIX/bin
#cp gffread $PREFIX/bin
#cp gtf_to_sam $PREFIX/bin
#cp cuffnorm $PREFIX/bin
#cp cuffquant $PREFIX/bin
