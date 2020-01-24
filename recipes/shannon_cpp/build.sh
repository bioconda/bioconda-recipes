#!/bin/bash

mkdir -p  "$PREFIX/bin"

cd shannon-*

cmake .
make

cp shannon_cpp $PREFIX/bin/
cp syrupy.py $PREFIX/bin/
