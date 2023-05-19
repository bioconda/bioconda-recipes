#!/bin/bash
set -euo pipefail

export CPATH=$PREFIX/include

mkdir build
cd build 
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX ..
make 
make install
