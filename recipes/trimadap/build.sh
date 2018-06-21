#!/bin/bash

mkdir -p $PREFIX/bin

sed -i "1d" Makefile
export LIBRARY_PATH="$PREFIX/lib"
export C_INCLUDE_PATH="$PREFIX/include"
make
mv trimadap-mt  $PREFIX/bin
