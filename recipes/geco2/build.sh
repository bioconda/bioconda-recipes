#! /bin/bash
export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib

cd src 
cmake .
make -j8
mkdir -p ${PREFIX}/bin
mv GeCo2 ${PREFIX}/bin
mv GeDe2 ${PREFIX}/bin
