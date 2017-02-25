#!/bin/bash
set -eu -o pipefail
mkdir -p build
cd build
if [ "$(uname)" == "Darwin" ]; then
export CXX_FLAGS='-std=c++11 -stdlib=libc++'
export CXXFLAGS="${CXXFLAGS}  -std=c++11 -stdlib=libc++"
export CMAKE_CXX_FLAGS='-stdlib=libc++'
export LDFLAGS=' -stdlib=libc++'
export LD_FLAGS=' -stdlib=libc++'
export CMAKE_LDFLAGS=' -stdlib=libc++'
fi
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DBOOST_ROOT=$PREFIX -DBoost_NO_SYSTEM_PATHS=ON -DBoost_DEBUG=ON ..
make VERBOSE=1
mv ExpansionHunter ${PREFIX}/bin/.
