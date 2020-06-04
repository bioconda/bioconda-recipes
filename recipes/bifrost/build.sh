#!/bin/bash

mkdir build
pushd build

# Cmake is having trouble finding the sysroot with conda so we're giving it a little help...
if [[ ${HOST} =~ .*darwin.* ]]; then
	cmake -DCOMPILATION_ARCH=x86-64 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}" ..
else
	cmake -DCOMPILATION_ARCH=x86-64 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake" ..
fi

make VERBOSE=1
make install

popd
