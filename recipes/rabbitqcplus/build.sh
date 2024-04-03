#!/bin/bash

export CC=${CC:-gcc}
export CXX=${CXX:-g++}

export LIBRARY_DIRS="$LIBRARY_DIRS $PREFIX/lib"

make
make install

