#!/bin/bash
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
export CPATH=${PREFIX}/include
export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
cmake -H. -Bbuild -DPYTHON_EXECUTABLE:FILEPATH=$PYTHON -DCMAKE_BUILD_TYPE=Generic
cmake --build build -j 2
mkdir -p $PREFIX/bin
mv bin/* $PREFIX/bin
PYVER=`python -c 'import sys; print(str(sys.version_info[0])+"."+str(sys.version_info[1]))'`
mkdir -p $PREFIX/lib/python$PYVER/site-packages
mv lib/*cpython* $PREFIX/lib/python$PYVER/site-packages
mv lib/* $PREFIX/lib
