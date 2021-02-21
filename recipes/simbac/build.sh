#!/bin/bash

mkdir -p $PREFIX/bin
${CC} *.cpp -lgsl -lgslcblas -lm -O2 -L$PREFIX/lib -I$PREFIX/include -o $PREFIX/bin/SimBac
