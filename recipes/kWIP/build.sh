#!/bin/bash

BINARY_HOME=$PREFIX/bin

git clone https://github.com/kdmurray91/kWIP.git
cd kWIP
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=${BINARY_HOME}
make
make test
make install