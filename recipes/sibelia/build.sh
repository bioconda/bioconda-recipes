#!/bin/bash

cd build
cmake ../src -DCMAKE_INSTALL_PREFIX=${PREFIX}
make
make install
