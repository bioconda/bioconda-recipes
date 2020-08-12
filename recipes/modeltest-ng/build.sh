#!/bin/bash

mkdir -p build
cd build

cmake -DUSE_MPI=ON ..
make
cp ../bin/modeltest-ng ${PREFIX}/bin/
