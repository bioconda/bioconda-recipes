#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
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

touch data/mapref-3.0.fna data/mapref-3.0.fna.mscluster data/mapref-3.0.fna.ncbitax data/mapref-3.0.fna.otutax data/mapref-3.0.gold.fna data/mapref-3.0.gold.fna.mscluster data/mapref-3.0.gold.fna.ncbitax data/mapref-3.0.fna.otutax.97.ncbitax data/mapref-3.0.otus.info

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

./bootstrap

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* libs/eutils/

./configure --prefix="${PREFIX}" \
	--disable-option-checking --disable-dependency-tracking --enable-silent-rules \
	CXXFLAGS="${CXXFLAGS}" \
	CXX="${CXX}" \
	CC="${CC}" \
	CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}"

make -j"${CPU_COUNT}"
make install
