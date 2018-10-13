#!/bin/bash
cd HMMcopy
cmake .
make
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
