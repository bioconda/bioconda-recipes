#!/bin/bash

make clean
make novoBreak LIBPATH=-L$PREFIX/lib INCLUDE=-I$PREFIX/include
mkdir -p $PREFIX/bin
cp novoBreak $PREFIX/bin
