#!/bin/bash

export CPP_INCLUDE_PATH="${PREFIX}/include"
export CXX_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

cd sources

make
chmod +x g_baypass
mkdir -p $PREFIX/bin
cp g_baypass ${PREFIX}/bin/
