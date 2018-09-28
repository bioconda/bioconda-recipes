#!/bin/bash

export CXXFLAGS="${CXXFLAGS} -O3"

# conda on macOS will fall back to libstdc++
# which lacks a ton of standard C++11 headers
if [[ $(uname) == Darwin ]]; then
	export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
fi

./configure --prefix="${PREFIX}" --with-boost="${PREFIX}" --with-boost-libdir="${PREFIX}"/lib

make
make install
