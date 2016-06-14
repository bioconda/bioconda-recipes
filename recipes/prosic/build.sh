#!/bin/bash -euo

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

cmake CMakeLists.txt && make
cp bin/prosic-call $PREFIX/bin

$PYTHON setup.py install
