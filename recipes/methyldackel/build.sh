#!/bin/bash
make install CC=$CC CFLAGS="-O3 -Wall -I$PREFIX/include" LIBS="-L$PREFIX/lib" LIBBIGWIG="$PREFIX/lib/libBigWig.a" prefix=$PREFIX/bin
