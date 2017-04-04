#!/bin/bash

mkdir -p $PREFIX/lib $PREFIX/bin
make
install *.o $PREFIX/lib/
install gtest $PREFIX/bin/
install threads $PREFIX/bin/

