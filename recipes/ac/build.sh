#! /bin/bash
export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib

cd src 
cmake -DCMAKE_C_FLAGS="$CFLAGS -fcommon"
make CC=$CC CFLAGS="$CFLAGS -fcommon"
mkdir -p ${PREFIX}/bin
mv AC ${PREFIX}/bin
