#!/bin/bash

set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

CFLAGS="-L${PREFIX}/lib" ./configure --prefix=$PREFIX
make install
