#!/bin/bash

# Make m4 accessible to bison
# https://github.com/conda-forge/bison-feedstock/issues/7#issuecomment-431602144
export M4=m4

if [ "$(uname)" == Darwin ] ; then
    CXXFLAGS="$CXXFLAGS -fopenmp -pthread"
    CFLAGS="$CFLAGS -fopenmp -pthread"

    # Can turn off PREFETCH in CMakeLists.txt as a crude fix.
    #sed -i '.tmp' 's/ENABLE_PREFETCH  ON/ENABLE_PREFETCH  OFF/' CMakeLists.txt
fi

export CMAKE_INSTALL_PREFIX="$PREFIX $CMAKE_PLATFORM_FLAGS[@] $SRC_DIR"

make  

mkdir -p $PREFIX/bin

cp bin/epa-ng $PREFIX/bin

