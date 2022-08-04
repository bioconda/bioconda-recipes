#!/bin/sh
# fix an issue to allow it to compile on macosx with clang
# does not affect the linux build
# this is has been fixed in newer versions: https://github.com/samtools/samtools/issues/22
sed -i.bak -E 's/(inline void __ks_insertsort_)/static \1/g' ksort.h
make INCLUDES="-I. -I$PREFIX/include -I$PREFIX/include/ncurses" LIBCURSES="-L$PREFIX/lib -lncurses -ltinfo" LIBPATH="-L$PREFIX/lib" CC=$CC CFLAGS="-g -Wall -O2 -I$PREFIX/include -L$PREFIX/lib"
mkdir -p $PREFIX/bin
mv samtools $PREFIX/bin