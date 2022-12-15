#!/bin/bash

mkdir -p $PREFIX/bin
export MACHTYPE=x86_64
make CC=gcc CXX=g++
cp psmc $PREFIX/bin
cd utils && make CC=gcc CXX=g++
cp utils/* $PREFIX/bin
