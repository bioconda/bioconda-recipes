#!/bin/bash
set -ex

export C_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

export CFLAGS="${CFLAGS} -DUSE_HTSLIB=1"
export CXXFLAGS="${CXXFLAGS} -DUSE_HTSLIB=1"

# Build and install the binary
make CC="${CC}" CXX="${CXX}" AR="${AR}"
mkdir -p ${PREFIX}/bin
install -v -m 755 bin/taffy ${PREFIX}/bin/

# Build and install the Python package bindings
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation --no-cache-dir