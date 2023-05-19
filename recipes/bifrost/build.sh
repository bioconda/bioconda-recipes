#!/bin/bash

mkdir build
pushd build

# Cmake is having trouble finding the sysroot with conda so we're giving it a little help...
if [[ ${HOST} =~ .*darwin.* ]]; then
	cmake -DCMAKE_BUILD_TYPE=Release -DCOMPILATION_ARCH=OFF -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}" ..
else
	cmake -DCMAKE_BUILD_TYPE=Release -DCOMPILATION_ARCH=OFF -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake" ..
fi

make VERBOSE=1
make install

popd
