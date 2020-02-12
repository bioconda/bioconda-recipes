#!/bin/bash
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
if [[ $(uname -s) == "Darwin" ]]; then
    make CC=$CC LIBS="$LDFLAGS -lm -lz -lpthread" INCLUDES="$CFLAGS" -j${CPU_COUNT}
else
    make CC=$CC LIBS="$LDFLAGS -lm -lz -lpthread -lrt" INCLUDES="$CFLAGS" -j${CPU_COUNT}
fi
install -m 0755 paladin ${PREFIX}/bin
