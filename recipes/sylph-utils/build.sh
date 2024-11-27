#!/bin/bash
mkdir build
cd build
cmake ${CMAKE_ARGS} ..
make
make install
