#!/bin/bash

mkdir -p $PREFIX/bin

cd src
make CC=$CXX CXX=$CXX
cp sam2pairwise $PREFIX/bin
