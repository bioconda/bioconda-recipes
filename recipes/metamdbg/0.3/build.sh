#!/bin/bash


mkdir -p $PREFIX/bin

export CPATH=${PREFIX}/include

mkdir build
cd build
cmake ..

make

cp ./bin/metaMDBG $PREFIX/bin
