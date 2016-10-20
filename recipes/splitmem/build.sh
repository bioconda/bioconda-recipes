#!/bin/bash

mkdir -p $PREFIX/bin

if [ `uname` == Darwin ]; then
g++ -std=c++0x -stdlib=libc++ -O3 -o splitMEM splitMEM.cc
else
g++ -std=c++0x -O3 -o splitMEM splitMEM.cc
fi

cp splitMEM $PREFIX/bin


