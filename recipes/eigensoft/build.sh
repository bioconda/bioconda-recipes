#!/bin/bash
find src -name "*.o" -delete
rm bin/*
cd src
export OPENBLAS=$PREFIX
make clean
make 
make install
cd ..
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin/
