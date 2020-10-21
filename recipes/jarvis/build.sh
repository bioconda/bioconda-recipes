#! /bin/bash
export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib

cd src 
make CC=$CC
mkdir -p ${PREFIX}/bin
mv JARVIS ${PREFIX}/bin
