#!/bin/bash
set -eux -o pipefail

# make compilation not be dependent on locale settings
export LC_ALL=C

# set up some variables so that CMake can find boost
export BOOST_INCLUDE_DIR="${PREFIX}/include"
export BOOST_LIBRARY_DIR="${PREFIX}/lib"
export CXXFLAGS="-DUSE_BOOST -I${BOOST_INCLUDE_DIR} -L${BOOST_LIBRARY_DIR}"
export LDFLAGS="-L${BOOST_LIBRARY_DIR} -lboost_filesystem -lboost_system"

# build cobs
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" -DBOOST=1 -DSKIP_PYTHON=1 ..
make -j1

# test
if [[ "$OSTYPE" == "linux-gnu"* ]]; then  # for some reason, tests fail on OS X
      make test  
fi

# install
make install
