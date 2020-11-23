#!/bin/bash
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export BOOST_INCLUDE=$PREFIX/include
./configure.py --no-pbbam --sub
make init-submodule
make

mkdir -p $PREFIX/bin
cp src/cpp/pbdagcon $PREFIX/bin
cp src/cpp/dazcon $PREFIX/bin
