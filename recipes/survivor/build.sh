#!/bin/bash

mkdir -p $PREFIX/bin
sed -i.bak "s#g++#$CXX#g" Debug/makefile
cd Debug
make
cp SURVIVOR $PREFIX/bin
