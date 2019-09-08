#!/bin/bash
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make CC=$CC LIBS="$LDFLAGS -lm -lz -lpthread -lrt" INCLUDES="$CFLAGS" -j${CPU_COUNT}
install -m 0755 paladin ${PREFIX}/bin
