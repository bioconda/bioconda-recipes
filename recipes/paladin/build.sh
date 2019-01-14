#!/bin/bash
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make INCLUDES=$PREFIX/include -j${CPU_COUNT}
install -m 0755 paladin ${PREFIX}/bin

