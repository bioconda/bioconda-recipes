#!/usr/bin/env bash

mkdir -p $PREFIX/include
cp -r include/tbb include/serial $PREFIX/include
mkdir -p $PREFIX/lib

if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  # On Linux, there's more variability, so lets build from scratch
  make -j 1 prefix=$PREFIX
  cp build/linux*_release/*.so* $PREFIX/lib
fi
if [ "$(uname -s)" == "Darwin" ]; then
  # On OSX, just copy the pre-built binaries
  DYNAMIC_EXT="dylib"
  cp lib/*.dylib $PREFIX/lib
fi

