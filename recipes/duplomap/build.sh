#!/bin/bash -e

export C_INCLUDE_PATH="$BUILD_PREFIX/include"
export LIBRARY_PATH="$BUILD_PREFIX/lib"
export CFLAGS="-L$BUILD_PREFIX/lib"
export RUSTFLAGS="-L$BUILD_PREFIX/lib -lz"
./build --install "$PREFIX"

