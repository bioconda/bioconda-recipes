#!/bin/bash
set -eu

echo "HTSLIB_CPPFLAGS=-I$PREFIX/include" > Makefile.local
echo "HTSLIB_LDFLAGS=-L$PREFIX/lib -Wl,-rpath $PREFIX/lib" >> Makefile.local
./INSTALL $PREFIX
mkdir -p $PREFIX/bin
cp pindel pindel2vcf pindel2vcf4tcga sam2pindel $PREFIX/bin
