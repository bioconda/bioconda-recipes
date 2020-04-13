#!/bin/sh
set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export CFLAGS="-I$PREFIX/include"
export CPATH=${PREFIX}/include
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

mkdir -p ${PREFIX}/bin

#compile
cmake -DGSL_LIBRARIES=${PREFIX}/include -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -DBoost_DEBUG=ON -DCMAKE_CXX_FLAGS="-std=c++11" -DCMAKE_PREFIX_PATH="$PREFIX" ${PREFIX}/bin
make

# for debugging
ls -l
ls -l $PREFIX/bin

#make everything executable in case
chmod +x $PREFIX/bin/*
