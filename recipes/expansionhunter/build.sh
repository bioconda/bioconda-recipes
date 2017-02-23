#!/bin/bash
set -eu -o pipefail
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DBOOST_ROOT=$PREFIX -DBoost_NO_SYSTEM_PATHS=ON -DBoost_DEBUG=ON ..
make
mv ExpansionHunter ${PREFIX}/bin/.
