#!/bin/bash

mkdir build
cd build
cmake .. && make

mkdir -p $PREFIX/bin
cp XXmotif $PREFIX/bin
