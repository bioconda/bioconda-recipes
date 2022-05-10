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
if [ ! "$(uname)" = 'Darwin' ]
then
  mkdir build_mpi
  pushd build_mpi
     CXX=mpicxx cmake -DUSE_MPI=ON ..
     make
     install -d ${PREFIX}/bin
     install ../bin/raxml-ng-mpi ${PREFIX}/bin
  popd
fi
