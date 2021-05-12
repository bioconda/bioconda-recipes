#!/bin/bash
pushd autogrid
ln -s $BUILD_PREFIX/bin/tcsh $BUILD_PREFIX/bin/csh 
./configure PREFIX=$PREFIX
make
make check
mkdir -p $PREFIX/bin
make install PREFIX=$PREFIX
unlink $BUILD_PREFIX/bin/csh
