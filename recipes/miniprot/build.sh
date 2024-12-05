#!/bin/bash

set -xe

make -j"${CPU_COUNT}" CC=$CC CFLAGS="$CFLAGS -I$PREFIX/include" LIBS="$LDFLAGS -L$PREFIX/lib -lpthread -lz -lm"

if [ ! -d $PREFIX/bin ] ; then
	mkdir -p $PREFIX/bin
fi

if [ ! -d $PREFIX/share/man/man1 ] ; then
	mkdir -p $PREFIX/share/man/man1
fi

cp miniprot $PREFIX/bin
chmod a+x $PREFIX/bin/miniprot

cp miniprot.1 $PREFIX/share/man/man1

