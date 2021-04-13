#!/bin/bash

mkdir -p $PREFIX/bin
${CC} *.cpp -lgsl -lgslcblas -lm -O2 -lstdc++ -L$PREFIX/lib -I$PREFIX/include -o $PREFIX/bin/SimBac
