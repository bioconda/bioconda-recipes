#!/bin/bash
make -j ${CPU_COUNT} install CC=$CC CFLAGS="-O3 -Wall -I$PREFIX/include" LIBS="-L$PREFIX/lib" LIBBIGWIG="$PREFIX/lib/libBigWig.a" prefix=$PREFIX/bin
