#!/bin/bash
mkdir -p build
cd build
mv ../conda_build.sh .
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX ..
make
make install
