#! /bin/bash
export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib

cd src 
make CC=$CC CFLAGS="-Wall -O3" -j8
mkdir -p ${PREFIX}/bin
mv GeCo3 ${PREFIX}/bin
mv GeDe3 ${PREFIX}/bin
