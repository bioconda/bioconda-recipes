#!/bin/bash

mkdir -p $PREFIX/lib $PREFIX/bin $PREFIX/include
make
install *.o -v $PREFIX/lib/
install *.h -v $PREFIX/include/
install gtest $PREFIX/bin/
install threads $PREFIX/bin/
