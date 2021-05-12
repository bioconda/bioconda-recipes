#!/bin/bash
pushd autodock
ln -s $BUILD_PREFIX/bin/tcsh $BUILD_PREFIX/bin/csh 
./configure PREFIX=$PREFIX
make
make check
make install
unlink $BUILD_PREFIX/bin/csh
