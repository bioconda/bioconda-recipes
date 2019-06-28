#!/usr/bin/bash

make -e CC=$CC CXX=$CXX
mkdir -p $PREFIX/bin

cp ghostz $PREFIX/bin
