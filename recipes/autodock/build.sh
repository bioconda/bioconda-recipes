#!/bin/bash
pushd autodock
ln -s $BUILD_PREFIX/bin/tcsh $BUILD_PREFIX/bin/csh 
./configure PREFIX=$PREFIX
make
make check
mkdir -p $PREFIX/bin
install -c autodock4 autodock4.omp $PREFIX/bin
unlink $BUILD_PREFIX/bin/csh
