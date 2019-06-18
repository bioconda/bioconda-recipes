#!/bin/bash

# pthreads
mkdir build_pthreads
pushd build_pthreads
   cmake ..
   make
   install -d ${PREFIX}/bin
   install ../bin/raxml-ng ${PREFIX}/bin
popd

# mpi
mkdir build_mpi
pushd build_mpi
   cmake -DUSE_MPI=ON ..
   make
   install -d ${PREFIX}/bin
   install ../bin/raxml-ng ${PREFIX}/bin/raxml-ng-MPI
popd
