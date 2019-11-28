#!/bin/bash
set -eu -o pipefail

mkdir -p build
sed -i 's/Boost_USE_STATIC_LIBS ON/Boost_USE_STATIC_LIBS OFF/' CMakeLists.txt
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DBOOST_ROOT=$PREFIX -DBoost_NO_SYSTEM_PATHS=ON -DBoost_DEBUG=ON ..
make install
