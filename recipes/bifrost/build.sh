#!/bin/bash

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${PREFIX}/lib
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib
export PATH=$PATH:${PREFIX}/lib
export CPATH=$CPATH:${PREFIX}/include
export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:${PREFIX}/include

export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir build
cd build

# Cmake is having trouble finding the sysroot with conda so we're giving it a little help...
if [[ ${HOST} =~ .*darwin.* ]]; then

	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}" ..
else
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake" ..
fi

make
make install
