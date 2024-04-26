#!/bin/bash

mkdir -p $PREFIX/bin

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

meson setup build --prefix=$PREFIX --strip
cd build
ninja -v install
