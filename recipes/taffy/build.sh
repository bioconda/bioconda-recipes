#!/bin/bash
set -ex

export CFLAGS="${CFLAGS} -DUSE_HTSLIB=1"
export CXXFLAGS="${CXXFLAGS} -DUSE_HTSLIB=1"

export LDLIBS="${LDLIBS} -lhdf5_cpp -lhdf5 -lhts"
export LIBRARY_PATH="${PREFIX}/lib"

cd taffy/submodules/abPOA
make CC="${CC}" CXX="${CXX}" PREFIX=$(pwd) EXTRA_FLAGS="-I${PREFIX}/include -L${PREFIX}/lib" -j"${CPU_COUNT}"
cd ../../../

# Build and install the binary
make CC="${CC}" CXX="${CXX}" HALDIR="${SRC_DIR}/taffy/submodules/hal" sonLibRootDir="${SRC_DIR}/taffy/submodules/sonLib" -j"${CPU_COUNT}"
mkdir -p ${PREFIX}/bin
install -v -m 755 bin/taffy ${PREFIX}/bin/ 

# Build and install the Python package bindings
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation --no-cache-dir