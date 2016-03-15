#!/bin/bash
cd src
sed -i s/-lgsl/-llapacke -lgsl/g Makefile
make 
cd ..
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
