#!/bin/bash

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX ..
make
make install
