#!/bin/bash

export CXXFLAGS="-std=c++23 -funroll-loops -ftree-vectorize -fopenmp -Wall -Wextra -O3 -g -mtune=native -Wno-unknown-pragmas -I${PREFIX}/include -Wno-error=deprecated-declarations -Wno-error=unused-function -Wno-error=type-limits -fpermissive -Wno-error"
export LDFLAGS="-lhts -lfmt -Wl,-rpath=${PREFIX}/lib -L${PREFIX}/lib"
export CXX=${CXX:-g++}

# Update CONDA_PREFIX for the Makefile
export CONDA_PREFIX="${PREFIX}"


# Build the project - use make -e to prefer environment variables over Makefile settings
make -e -j 10

# Install the binary
mkdir -p ${PREFIX}/bin
install -m 755 tandemtwister ${PREFIX}/bin/