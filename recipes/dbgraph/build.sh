#!/bin/bash

mkdir -p $PREFIX/bin

cd Graph2Pro
make clean
make CXX=$CXX
#make check

cp DBGraph2Pro $PREFIX/bin/DBGraph2Pro
cp DBGraphPep2Pro $PREFIX/bin/DBGraphPep2Pro
