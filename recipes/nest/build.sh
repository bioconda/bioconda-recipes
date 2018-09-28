#!/bin/sh

export MPI_FLAGS=--allow-run-as-root

if [ $(uname) == Linux ]; then
    export MPI_FLAGS="$MPI_FLAGS;-mca;plm;isolated"
fi

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
      -Dwith-mpi=ON \
      -Dwith-openmp=ON \
      -Dwith-python=ON \
      ..

make -j2
make install
# this is needed to make the python bindings work
cp $PREFIX/lib64/* $PREFIX/lib -r
