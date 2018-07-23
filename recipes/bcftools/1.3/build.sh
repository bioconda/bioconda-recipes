#!/bin/sh
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make plugins
make prefix=$PREFIX install
