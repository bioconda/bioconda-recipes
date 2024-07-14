#!/bin/bash
make CC=$CC CXX=$CXX 
mkdir -p $PREFIX/bin
cp squigulator $PREFIX/bin/squigulator
