#!/bin/bash

INCLUDE=$CONDA_DEFAULT_ENV/include
${GCC} -I $INCLUDE -std=c++14 -lpthread  binstrings.cpp -lstdc++ -lrt -lm -o binstrings 
cp binstrings $PREFIX/bin
