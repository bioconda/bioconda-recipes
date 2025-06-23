#!/bin/bash

mkdir -p ${PREFIX}/bin

sed -i 's/c++ \-std=c++11/\$(CXX) \-std=c++11/g' Makefile
make all
cp {ripser,ripser-debug,ripser-coeff} ${PREFIX}/bin
