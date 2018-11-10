#!/bin/bash
set -eu -o pipefail
mkdir -p build
cd build
if [ "$(uname)" == "Darwin" ]; then
export CXX_FLAGS='-std=c++11 -stdlib=libc++'
export CXXFLAGS="-std=c++11 -stdlib=libc++"
export CMAKE_CXX_FLAGS='-stdlib=libc++'
export LDFLAGS='-stdlib=libc++'
export LD_FLAGS='-stdlib=libc++'
export CMAKE_LDFLAGS='-stdlib=libc++'
fi
export BOOST_ROOT=${PREFIX}
export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
cmake ..
make
mv ExpansionHunter ${PREFIX}/bin/.
