#!/bin/bash
mkdir -p ${PREFIX}/bin
sh autogen.sh
./configure --prefix ${PREFIX} --enable-igzip
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make
make install
