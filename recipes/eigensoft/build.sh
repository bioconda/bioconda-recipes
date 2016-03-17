#!/bin/bash
cd src
sed -i -e 's/-Wl,-Bdynamic//g' Makefile
sed -i -e 's/-Wl,-Bstatic//g' Makefile
export OPENBLAS=$PREFIX
make 
cd ..
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
