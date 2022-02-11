#!/bin/bash 
make CC=$CXX
mkdir -p $PREFIX/bin
cp mstmap $PREFIX/bin
