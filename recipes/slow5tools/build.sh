#!/bin/bash
./configure
make  CC=$CC CXX=$CXX
mkdir -p $PREFIX/bin
cp slow5tools $PREFIX/bin/slow5tools
