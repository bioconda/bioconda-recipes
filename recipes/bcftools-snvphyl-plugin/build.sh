#!/bin/bash

export VERSION="1.9"
export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

ln -sf ${CC} ${PREFIX}/bin/gcc

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/bcftools

#copy plugin source to be the bcftools plugin directory
cp -f snvphyl/bcfplugins/filter_snv_density.c bcftools-${VERSION}/plugins/

# Compile htslib and bcftools with filter_snv_density plugin.
pushd htslib-${VERSION}
autoreconf -if
./configure --prefix="${PREFIX}" --disable-bz2 \
	--disable-lzma --enable-libcurl --enable-plugins \
	--with-libdeflate CC="${CC}" CFLAGS="${CFLAGS}" \
	LDFLAGS="${LDFLAGS}" CPPFLAGS="${CPPFLAGS}"
make -j"${CPU_COUNT}"
popd

pushd bcftools-${VERSION}
autoreconf -if
./configure --prefix="${PREFIX}" --disable-bz2 --disable-lzma \
	CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" CPPFLAGS="${CPPFLAGS}"
make -j"${CPU_COUNT}"
popd

#Move custom bcftools plugin to the ~/libexec/bcftools directory.
mv bcftools-${VERSION}/plugins/filter_snv_density.so ${PREFIX}/libexec/bcftools/

rm -f ${PREFIX}/bin/gcc
