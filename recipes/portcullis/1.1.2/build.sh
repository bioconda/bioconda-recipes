#!/bin/sh

set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export CFLAGS="-I$PREFIX/include -fPIC"
export CXXFLAGS="-I$PREFIX/include -fPIC"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

# Build boost
# ./build_boost.sh
cd deps/boost
./bootstrap.sh --prefix=build --with-libraries=chrono,exception,program_options,timer,filesystem,system,stacktrace
./b2 --ignore-site-config headers
./b2 --ignore-site-config cxxflags="-fPIC -no-pie --std=c++11" link=static install
cd ../..

./autogen.sh
./configure --disable-silent-rules --disable-dependency-tracking --prefix=$PREFIX
make V=1
make V=1 check
make install
