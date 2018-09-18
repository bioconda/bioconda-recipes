#!/bin/bash
set -eu -o pipefail

cd build
cmake  -DINSTALL_PREFIX=ON -DCMAKE_INSTALL_PREFIX=$PREFIX -DINSTALL_ROOT=ON -DCMAKE_BUILD_TYPE=Release -DBOOST_ROOT=$PREFIX -DBoost_NO_SYSTEM_PATHS=ON ..
make install
