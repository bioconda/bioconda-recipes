#!/bin/bash

mkdir -p $PREFIX/bin

mkdir build
cd build
export MPICXX=$PREFIX/bin
export OMPI_MCA_mpi_show_handle_leaks=1
cmake . -DCMAKE_INSTALL_PREFIX=$PREFIX/bin ..
make HAVE_LIBZ=y HAVE_LIBBZ2=y
cp Ray $PREFIX/bin
