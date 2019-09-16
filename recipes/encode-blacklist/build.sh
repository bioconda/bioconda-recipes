#!/bin/bash
export LIBRARY_PATH=${PREFIX}/lib
mkdir -p $PREFIX/bin/
sed -i.bak "s#g++#${CXX}#" Makefile
make
cp Blacklist $PREFIX/bin/

