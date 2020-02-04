#!/bin/bash
export LD_LIBRARY_PATH=${PREFIX}/lib
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
export C_INCLUDE_PATH=${PREFIX}/include
cmake -H. -Bbuild
cmake --build build
mkdir -p $PREFIX/bin
mv bin/* $PREFIX/bin
PYVER=`python -c 'import sys; print(str(sys.version_info[0])+"."+str(sys.version_info[1]))'`
mkdir -p $PREFIX/lib/python-$PYVER/site-packages
mv lib/* $PREFIX/lib/python-$PYVER/site-packages
