#! /bin/bash

mkdir -p $PREFIX/bin

if [[ "$(uname)" == "Linux" ]]; then

mkdir build
cd build
export CPATH=${BUILD_PREFIX}/include
export CXXPATH=${BUILD_PREFIX}/include
export CFLAGS="$CFLAGS -I$BUILD_PREFIX/include"
export CXXFLAGS="$CFLAGS -I$BUILD_PREFIX/include"
export LDFLAGS="$LDFLAGS -L$BUILD_PREFIX/lib"
cmake ..
make PgRC

fi

cp PgRC $PREFIX/bin
