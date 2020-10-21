#!/bin/bash

mkdir -p $PREFIX/bin
export CPATH=${PREFIX}/include

make CC=$GXX CXX=$GXX
cp lra $PREFIX/bin
