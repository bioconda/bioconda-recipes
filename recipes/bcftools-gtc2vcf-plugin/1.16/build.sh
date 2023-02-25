#!/bin/sh

export VERSION=1.16
export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CFLAGS="$CFLAGS -I$PREFIX/include"

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/libexec/bcftools

# Copy plugin source to the bcftools plugin directory.
cp gtc2vcf/affy2vcf.c bcftools/plugins/
cp gtc2vcf/gtc2vcf.c bcftools/plugins/
cp gtc2vcf/gtc2vcf.h bcftools/plugins/

# Compile htslib and bcftools with affy2vcf and gtc2vcf plugins.
pushd htslib
autoheader
(autoconf || autoconf)
./configure --disable-bz2 --disable-lzma --prefix=$PREFIX
make CC=$CC
popd

pushd bcftools
make
popd

# Move custom bcftools plugins to the ~/libexec/bcftools directory.
mv bcftools/plugins/affy2vcf.so $PREFIX/libexec/bcftools/
mv bcftools/plugins/fixref.so $PREFIX/libexec/bcftools/
mv bcftools/plugins/gtc2vcf.so $PREFIX/libexec/bcftools/
