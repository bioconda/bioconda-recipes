#!/bin/bash

make clean
make novoBreak LIBPATH=$PREFIX/lib INCLUDE=$PREFIX/include
mkdir -p $PREFIX/bin
cp novoBreak $PREFIX/bin
