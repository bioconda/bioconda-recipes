#!/bin/sh
make INCLUDES="-I. -I$PREFIX/include -I$PREFIX/include/ncurses" LIBCURSES="-L$PREFIX/lib -lncurses"
mkdir -p $PREFIX/bin
mv samtools $PREFIX/bin
mv bcftools/bcftools $PREFIX/bin
chmod a+rx bcftools/vcfutils.pl
mv bcftools/vcfutils.pl $PREFIX/bin
mkdir -p $PREFIX/lib
mv libbam.a $PREFIX/lib
mkdir -p $PREFIX/include/bam
mv ./* $PREFIX/include/bam/
