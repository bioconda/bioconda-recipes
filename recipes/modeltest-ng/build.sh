#!/bin/bash

mkdir -p ${PREFIX}/bin/
mkdir -p build
cd build 

# Build multithreaded version 
rm -rf *
cmake ..
make 
cp ../bin/modeltest-ng ${PREFIX}/bin/

# Build MPI version
rm -rf *
CXX=mpicxx cmake -DENABLE_MPI=ON ..
make
cp ../bin/modeltest-ng ${PREFIX}/bin/modeltest-ng-mpi

chmod +x ${PREFIX}/bin/modeltest-ng*
