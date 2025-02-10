#!/bin/bash
set -eux -o pipefail

# make compilation not be dependent on locale settings
export LC_ALL=C

# allows CMake to find BOOST
export BOOST_ROOT="${PREFIX}"

# build cobs
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" -DSKIP_PYTHON=1 ..
make -j1

# test
env CTEST_OUTPUT_ON_FAILURE=1 make test  

# install
make install
