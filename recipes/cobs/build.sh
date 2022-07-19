#!/bin/bash
set -eux -o pipefail

# make compilation not be dependent on locale settings
export LC_ALL=C

# set up some variables so that CMake can find boost
export BOOST_ROOT="${PREFIX}"

# build cobs
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" -DBOOST=1 -DSKIP_PYTHON=1 ..
make -j1

# test
env CTEST_OUTPUT_ON_FAILURE=1 make test  

# install
make install
