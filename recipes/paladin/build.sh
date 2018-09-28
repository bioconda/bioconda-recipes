#!/bin/bash
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make INCLUDES=$PREFIX/include INSTALLDIR=$PREFIX/bin install -j${CPU_COUNT}
