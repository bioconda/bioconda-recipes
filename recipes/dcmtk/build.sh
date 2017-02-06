#!/usr/bin/env bash

mkdir build
cd build

DCMTK_HOME=$PREFIX \
cmake \
	-D CMAKE_FIND_ROOT_PATH=${PREFIX} \
	-D CMAKE_INSTALL_PREFIX=${PREFIX} \
        -D CMAKE_BUILD_TYPE:STRING=Release \
	..

make -j${CPU_COUNT}
make install

