#!/bin/sh

export VERSION=1.9
export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CFLAGS="$CFLAGS -I$PREFIX/include"

CC=${CC}
CXX=${CXX}

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/libexec/bcftools

#copy plugin source to be the bcftools plugin directory 
cp snvphyl/bcfplugins/filter_snv_density.c bcftools-$VERSION/plugins/

# Compile htslib and bcftools with filter_snv_density plugin.
pushd htslib-$VERSION
autoheader
(autoconf || autoconf)
./configure --disable-bz2 --disable-lzma --prefix=$PREFIX
make
popd

pushd bcftools-$VERSION
make
popd

#Move custom bcftools plugin to the ~/libexec/bcftools directory.
mv bcftools-$VERSION/plugins/filter_snv_density.so $PREFIX/libexec/bcftools/
