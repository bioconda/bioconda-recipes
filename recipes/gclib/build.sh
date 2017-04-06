#!/bin/bash

mkdir -p $PREFIX/lib $PREFIX/bin $PREFIX/include
make
install *.o $PREFIX/lib/
install *.so $PREFIX/lib/
install *.h $PREFIX/include/
install gtest $PREFIX/bin/
install threads $PREFIX/bin/
