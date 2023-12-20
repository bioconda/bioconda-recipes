#!/bin/bash
set -eo pipefail

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} .. 
make 
make install
