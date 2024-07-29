#!/bin/bash

mkdir -p build
cd build

echo ${CMAKE_ARGS}
cmake ${SRC_DIR} ${CMAKE_ARGS}
make
make install
