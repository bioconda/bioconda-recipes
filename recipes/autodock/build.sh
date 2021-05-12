#!/bin/bash
pushd autodock
ln -s $PREFIX/bin/tcsh $PREFIX/bin/csh
./configure PREFIX=$PREFIX
make
make check
make install
