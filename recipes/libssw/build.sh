#!/bin/bash

# set path for libssw.so
export LIBRARY_PATH=${PREFIX}/lib
export C_INCLUDE_PATH=${PREFIX}/include:${PREFIX}/include/linux
export CPP_INCLUDE_PATH=${PREFIX}/include:${PREFIX}/include/linux
export CXX_INCLUDE_PATH=${PREFIX}/include:${PREFIX}/include/linux
export CPLUS_INCLUDE_PATH=${PREFIX}/include:${PREFIX}/include/linux
export JAVA_HOME="${PREFIX}/bin"
export LDFLAGS="-L$PREFIX/lib"

cd src
make
make java
chmod +x *
cp example_cpp ${PREFIX}/bin

for i in *.py
do
sed -i.bak 's#!/usr/bin/env python#!/opt/anaconda1anaconda2anaconda3/bin/python#' $i
done

cp *.py* ${PREFIX}/bin
cp ssw_test ${PREFIX}/bin
cp ssw.jar ${PREFIX}/bin
cp *.so ${PREFIX}/lib

# copy c/c++ files
cp *.h ${PREFIX}/include
cp ssw.c ${PREFIX}/include
cp ssw_cpp.cpp ${PREFIX}/include
