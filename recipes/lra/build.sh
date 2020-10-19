#!/bin/bash

mkdir -p $PREFIX/bin
git submodule init
git submodule update --recursive 

export CPATH=${PREFIX}/include

make 
cp lra $PREFIX/bin
