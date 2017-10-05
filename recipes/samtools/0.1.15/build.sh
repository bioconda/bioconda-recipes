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
