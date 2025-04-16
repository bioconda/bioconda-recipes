#!/bin/bash

# pthreads
mkdir build_pthreads
pushd build_pthreads
   cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ..
   make -j ${CPU_COUNT}
   install -d ${PREFIX}/bin
   install ../bin/raxml-ng ${PREFIX}/bin
popd

# mpi
if [ ! "$(uname)" = 'Darwin' ]
then
  mkdir build_mpi
  pushd build_mpi
     CXX=mpicxx cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DUSE_MPI=ON ..
     make -j ${CPU_COUNT}
     install -d ${PREFIX}/bin
     install ../bin/raxml-ng-mpi ${PREFIX}/bin
  popd
fi
