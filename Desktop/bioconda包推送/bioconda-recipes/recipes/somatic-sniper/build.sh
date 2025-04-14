#!/bin/bash
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX ../
make deps
make -j
make install
