#!/bin/bash

# conda on macOS will fall back to libstdc++
# which lacks a ton of standard C++11 headers
if [[ $(uname) == Darwin ]]; then
	export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
fi

mkdir -p build
cd build

cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DBOOST_ROOT="${PREFIX}" -DCMAKE_CXX_COMPILER=${CXX} ..

make VERBOSE=1
make install
