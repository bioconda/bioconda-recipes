#!/bin/bash

git submodule update --init
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make install ROOT="."
