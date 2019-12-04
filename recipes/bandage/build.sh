#!/bin/bash

# Run qmake to generate a Makefile
qmake Bandage.pro QMAKE_CXX=$CXX QMAKE_CC=$CC

# fix the makefile
sed -ie "s/isystem/I/" Makefile
# Build the program
make

# Install
cp Bandage $PREFIX/bin
