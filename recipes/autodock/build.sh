#!/bin/bash
pushd autodock
ln -s $PREFIX/bin/csh $PREFIX/bin/tcsh 
./configure PREFIX=$PREFIX
make
make check
make install
unlink $PREFIX/bin/csh
