#!/bin/bash


mkdir -p $PREFIX/bin

mkdir build
cd build

export CXXFLAGS=-ldeflate
cmake ..

make

cp ./bin/metaMDBG $PREFIX/bin
