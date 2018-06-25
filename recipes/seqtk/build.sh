#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

sed -i.bak 's/CC=.*//g' Makefile

make all
mkdir -p $PREFIX/bin
cp -f seqtk $PREFIX/bin/
