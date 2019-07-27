#!/bin/bash

cd fastSimBac_linux

sed -i.bak "s|/Users/garychen/software/boost_1_36_0|$PREFIX/include|g" makefile
sed -i.bak2 "s|g++|$CXX|g" makefile

make all

chmod a+x fastSimBac msformatter

cp fastSimBac $PREFIX/bin
cp msformatter $PREFIX/bin
