#!/bin/bash

INCLUDE=$CONDA_DEFAULT_ENV/include
${GCC} -I $INCLUDE -std=c++14 -lpthread diprofile.cpp -lstdc++ -lrt -lm -o  diprofile
cp diprofile $PREFIX/bin
