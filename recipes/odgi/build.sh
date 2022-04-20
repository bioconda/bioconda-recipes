#!/bin/bash
export LD_LIBRARY_PATH=${PREFIX}/lib
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
export C_INCLUDE_PATH=${PREFIX}/include
cmake -H. -Bbuild -DPYTHON_EXECUTABLE:FILEPATH=$PYTHON
cmake --build build -j 2
mkdir -p $PREFIX/bin
mv bin/* $PREFIX/bin
PYVER=`python -c 'import sys; print(str(sys.version_info[0])+"."+str(sys.version_info[1]))'`
mkdir -p $PREFIX/lib/python$PYVER/site-packages
mv lib/*cpython* $PREFIX/lib/python$PYVER/site-packages
mv lib/* $PREFIX/lib
