#!/bin/sh
sed -i.bak 's/-lcurses/-lncurses/' Makefile
if [ `uname` != Darwin ] ; then
    sed -i.bak 's/-lz/-lz -ltinfo/' Makefile
fi
sed -i.bak 's/\(inline void __ks_insertsort\)/static \1/'  ksort.h
export CFLAGS="$CFLAGS -I$PREFIX/include"
make
mkdir -p $PREFIX/bin
mv samtools $PREFIX/bin
mkdir -p $PREFIX/lib
mv libbam.a $PREFIX/lib
mkdir -p $PREFIX/include/bam
mv *.c *.o *.h *.1 $PREFIX/include/bam/
mv bcftools/bcftools bcftools/vcfutils.pl bcftools/bcf-fix.pl $PREFIX/bin
make -C misc maq2sam-short maq2sam-long wgsim
mv misc/maq2sam-short misc/maq2sam-long misc/wgsim $PREFIX/bin