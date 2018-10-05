#!/bin/bash

INCLUDE=$CONDA_DEFAULT_ENV/include
${GCC} -I $INCLUDE -std=c++14 -lpthread  corrprofile.cpp -lstdc++ -lrt -lm -o  corrprofile
cp corrprofile $PREFIX/bin
