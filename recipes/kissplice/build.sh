#!/bin/bash

mkdir -p ${PREFIX}/bin
mkdir -p work/bcalm
touch work/bcalm/README.md

mkdir -p build
cd build

# cmake command
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ..

# make commands
make -j1
#make test
make install
