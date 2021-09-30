#!/bin/sh

set -e

if [ "x$PREFIX" = "x" ]; then
  PREFIX=`.`
fi
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export LD_LIBRARY_PATH=${PREFIX}/lib:$LD_LIBRARY_PATH
export CMAKE_LIBRARY_PATH=${PREFIX}/lib:$CMAKE_LIBRARY_PATH

BUILD_DIR=build
BASEDIR=`.`/`dirname $0`

rm -rf "$BASEDIR/$BUILD_DIR"
mkdir -p "$BASEDIR/$BUILD_DIR"
set -e
cd "$BASEDIR/$BUILD_DIR"
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$PREFIX" $* "$BASEDIR"
make -j 8
make install
cd $PREFIX
