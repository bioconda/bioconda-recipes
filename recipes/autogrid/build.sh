#!/bin/bash
pushd autogrid
ln -s $BUILD_PREFIX/bin/tcsh $BUILD_PREFIX/bin/csh 
./configure PREFIX=$PREFIX
make
make check
mkdir -p $PREFIX/bin
install -c autogrid4 $PREFIX/bin
unlink $BUILD_PREFIX/bin/csh
