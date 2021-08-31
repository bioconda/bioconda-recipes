#!/bin/sh
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make plugins CC=$CC CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
make prefix=$PREFIX CC=$CC CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" install
