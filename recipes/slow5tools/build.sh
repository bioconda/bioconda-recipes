#!/bin/bash
./configure
make
mkdir -p $PREFIX/bin
cp slow5tools $PREFIX/bin/slow5tools
