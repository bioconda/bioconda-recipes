#!/bin/bash

mkdir -p ${PREFIX}/bin
cd src/
# without -fpermissive, this fails with GCC7 due to bad style
export LIBRARY_PATH=${PREFIX}/lib
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
make CXXFLAGS+='-fpermissive'
cp ../bin/tandem.exe ${PREFIX}/bin/xtandem
