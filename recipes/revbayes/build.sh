#!/usr/bin/env bash

cd ./projects/cmake

# build non-mpi version
rm -rf build
./build.sh -DCMAKE_PREFIX_PATH=$PREFIX
mv rb ${PREFIX}/bin

# build mpi version
rm -rf build-mpi
./build.sh -mpi true -DCMAKE_PREFIX_PATH=$PREFIX
mv rb-mpi ${PREFIX}/bin
