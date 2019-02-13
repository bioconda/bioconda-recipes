#!/bin/bash

mkdir -p $PREFIX/bin
# Copy the precompiled ideas binary.
cp ./bin/linux/ideas $PREFIX/bin
chmod +x $PREFIX/bin/ideas
# Compile and install prepMat from source.
cd ./src
make -f makefile
cp ./prepMat $PREFIX/bin
