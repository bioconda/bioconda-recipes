#!/bin/bash

mkdir -p $PREFIX/bin

cd Graph2Pro
make clean
make CXX=$BUILD_PREFIX/bin/x86_64-conda_cos6-linux-gnu-g++
#make check

cp DBGraph2Pro $PREFIX/bin/DBGraph2Pro
cp DBGraphPep2Pro $PREFIX/bin/DBGraphPep2Pro
