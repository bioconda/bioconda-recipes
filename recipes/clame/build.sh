#!/bin/bash
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

echo "Binning compilation"
cd binning
make CPP=${CXX}
mkdir -p $PREFIX/bin
cp binning $PREFIX/bin
cd ..

echo "genFm9 compilation"
cd genFm9
make CPP=${CXX} ILIB=$C_INCLUDE_PATH LLIB=$LIBRARY_PATH
cp genFm9 $PREFIX/bin
cd ..

echo "mapping compilation"
cd mapping
make CPP=${CXX} ILIB=$C_INCLUDE_PATH LLIB=$LIBRARY_PATH
cp mapping $PREFIX/bin
cd ..

echo "clame compilation"
make CPP=${CXX} ILIB=$C_INCLUDE_PATH LLIB=$LIBRARY_PATH
cp clame $PREFIX/bin

echo "Installation successful"

