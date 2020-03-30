#!/bin/bash
set -eu -o pipefail

mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DBOOST_ROOT=$PREFIX -DBoost_NO_SYSTEM_PATHS=ON -DBoost_DEBUG=ON -DBoost_USE_STATIC_LIBS=OFF ..
make install
