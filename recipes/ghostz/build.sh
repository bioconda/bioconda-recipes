#!/usr/bin/bash

make -e CC=$CC CXX=$CXX LAST_CC=$CXX
mkdir -p $PREFIX/bin

cp ghostz $PREFIX/bin
