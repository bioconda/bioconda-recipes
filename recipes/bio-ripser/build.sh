#!/bin/bash

mkdir -p ${PREFIX}/bin

sed -i.bak 's/c++ \-std=c++11/\$(CXX) \-std=c++14/g' Makefile
rm -rf *.bak

make all -j"${CPU_COUNT}"

install -v -m 755 ripser ripser-debug ripser-coeff "${PREFIX}/bin"
