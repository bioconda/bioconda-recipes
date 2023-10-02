#!/bin/bash

mkdir -p $PREFIX/bin

mkdir build
cd build
cmake ..
make

cp ./bin/metaMDBG $PREFIX/bin
