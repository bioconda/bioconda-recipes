#!/bin/bash
echo "SDSL compilation"
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

git clone https://github.com/simongog/sdsl-lite.git
cd sdsl-lite
./install.sh
cd ..

echo "Binning compilation"
cd binning
make CPP=${CXX}
mkdir -p $PREFIX/bin
cp binning $PREFIX/bin
cd ..

echo "genFm9 compilation"
cd genFm9
make CPP=${CXX}
cp genFm9 $PREFIX/bin
cd ..

echo "mapping compilation"
cd mapping
make CPP=${CXX}
cp mapping $PREFIX/bin
cd ..

echo "clame compilation"
make CPP=${CXX}
cp clame $PREFIX/bin

echo "Installation successful"

