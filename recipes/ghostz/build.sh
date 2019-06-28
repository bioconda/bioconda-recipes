#!/usr/bin/bash

make CC=$CC CXX=$CXX
mkdir -p $PREFIX/bin

cp ghostz $PREFIX/bin
