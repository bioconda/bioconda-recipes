#!/bin/bash

mkdir -p $PREFIX/bin

mkdir build
cd build
export MPICXX=$PREFIX/bin
export OMPI_MCA_mpi_show_handle_leaks=1
cmake . -DCMAKE_INSTALL_PREFIX=$PREFIX/bin ..
make
cp Ray $PREFIX/bin
