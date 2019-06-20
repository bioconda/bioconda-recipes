#!/bin/sh

set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

# Build boost
./build_boost.sh
./autogen.sh
./configure --disable-silent-rules --disable-dependency-tracking --disable-pykat-install --prefix=$PREFIX
make
make install
