#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14 -Wno-register -D_LIBCPP_DISABLE_AVAILABILITY -D_LIBCPP_ENABLE_CXX17_REMOVED_UNARY_BINARY_FUNCTION -D_LIBCPP_ENABLE_CXX17_REMOVED_BINDERS"
export CFLAGS="${CFLAGS} -O3"
export LC_ALL="en_US.UTF-8"
export BAM_ROOT="${PREFIX}"

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
sed -i.bak "s|$CFLAGS -std=c++03|$CXXFLAGS -std=c++14|" configure.ac
rm -f *.bak

sed -i.bak 's|#include <Eigen/Dense>|#include <eigen3/Eigen/Dense>|' src/abundances.h
sed -i.bak 's|#include <Eigen/Dense>|#include <eigen3/Eigen/Dense>|' src/abundances.cpp
sed -i.bak 's|#include <Eigen/Dense>|#include <eigen3/Eigen/Dense>|' src/jensen_shannon.h
sed -i.bak 's|#include <Eigen/Dense>|#include <eigen3/Eigen/Dense>|' src/sampling.h
sed -i.bak 's|#include <boost/tr1/unordered_map.hpp>|#include <boost/unordered_map.hpp>|' src/biascorrection.h
rm -f src/*.bak

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

make CXXFLAGS="${CXXFLAGS}" CFLAGS="${CFLAGS}" -j"${CPU_COUNT}"
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
