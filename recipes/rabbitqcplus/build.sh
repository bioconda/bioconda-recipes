#!/bin/bash

set -xe

export CC=${CC:-gcc}
export CXX=${CXX:-g++}

export LIBRARY_DIRS="$LIBRARY_DIRS $PREFIX/lib"

make -j"${CPU_COUNT}" BIOCONDA=1
make install

