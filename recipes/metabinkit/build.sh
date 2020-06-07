#!/usr/bin/env bash

export C_INCLUDE_PATH="${PREFIX}/include:${PREFIX}/include/bam"
export CPP_INCLUDE_PATH="${PREFIX}/include"
export CXX_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

# run the install script -C
./install.sh -i $PREFIX -C

