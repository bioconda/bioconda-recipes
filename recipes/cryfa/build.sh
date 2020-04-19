#! /bin/bash
export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
#export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib

mkdir -p $PREFIX/build
cd $PREFIX/build
rm CMakeCache.txt
cmake ..
make -j4
mkdir -p ${PREFIX}/bin
cp cryfa ${PREFIX}/bin
cp keygen ${PREFIX}/bin
cd ${PREFIX}
