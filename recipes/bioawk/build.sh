#!/bin/bash

export CPATH="$PREFIX/include"
export LIBRARY_PATH="$PREFIX/lib"

make CC=$CC

mkdir -p $PREFIX/bin
cp bioawk $PREFIX/bin
