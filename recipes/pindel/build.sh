#!/bin/bash
set -eu

echo "HTSLIB_CPPFLAGS=-I$PREFIX/include" > Makefile.local
echo "HTSLIB_LDFLAGS=-L$PREFIX/lib -Wl,-rpath $PREFIX/lib" >> Makefile.local
export CXXFLAGS="-D__STDC_LIMIT_MACROS -D__STDC_CONSTANT_MACROS"
./INSTALL $PREFIX
mkdir -p $PREFIX/bin
cp pindel pindel2vcf pindel2vcf4tcga sam2pindel $PREFIX/bin
