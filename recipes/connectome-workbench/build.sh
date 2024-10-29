#!/usr/bin/env bash

mkdir build
cd build

if [[ "$target_platform" == linux-* ]]; then
    export CXX_FLAGS="$CXX_FLAGS -lGL -lGLU"
fi

cmake $CMAKE_ARGS -GNinja \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:STRING=$PREFIX \
    -DCMAKE_CXX_FLAGS="$CXX_FLAGS" \
    ../src

cmake --build .

ctest --extra-verbose --output-on-failure .

cmake --install .
