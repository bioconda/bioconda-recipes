#!/bin/bash

mkdir -p ${PREFIX}/bin/

mkdir -p build
cd build

CXX=mpicxx cmake -DENABLE_MPI=ON ..
make
cp ../bin/modeltest-ng ${PREFIX}/bin/
