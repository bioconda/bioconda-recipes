#!/bin/sh

set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

# This package is a mess and vendors a LOT that hard-codes compilers
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
ln -s $CC ${PREFIX}/bin/gcc
ln -s $CXX ${PREFIX}/bin/g++

# Build and vendor boost
./build_boost.sh --toolset gcc
cp deps/boost/build/lib/*.so* ${PREFIX}/lib

#importing matplotlib fails, likely due to X
sed -i.bak "124d" configure.ac

./autogen.sh
export PYTHON_NOVERSION_CHECK="3.7.0"
./configure --disable-silent-rules --disable-dependency-tracking --prefix=$PREFIX
make
make install

unlink ${PREFIX}/bin/gcc
unlink ${PREFIX}/bin/g++
rm -rf $PREFIX/mkspecs
