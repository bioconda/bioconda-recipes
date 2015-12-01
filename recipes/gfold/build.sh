#!/bin/bash

LIBRARY_PATH=$PREFIX/lib CPATH=$PREFIX/include make

mkdir -p $PREFIX/bin
cp gfold $PREFIX/bin
