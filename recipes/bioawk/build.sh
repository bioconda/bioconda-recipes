#!/bin/bash

export CPATH="$PREFIX/include"
export LIBRARY_PATH="$PREFIX/lib"

make

mkdir -p $PREFIX/bin
cp bioawk $PREFIX/bin
