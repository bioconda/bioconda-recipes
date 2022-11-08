#!/bin/sh

set -e

if [ "x$PREFIX" = "x" ]; then
  PREFIX="$(pwd)"
fi

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export LD_LIBRARY_PATH=${PREFIX}/lib:$LD_LIBRARY_PATH
export CMAKE_LIBRARY_PATH=${PREFIX}/lib:$CMAKE_LIBRARY_PATH

BUILD_DIR=build
mkdir -p $BUILD_DIR

cd $BUILD_DIR
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$PREFIX" ../
make -j 8
make install
cd ..
