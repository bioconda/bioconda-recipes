#!/bin/bash

mkdir -p $PREFIX/bin
${CC} *.cpp -lgsl -lgslcblas -lm -O2 -o $PREFIX/bin/SimBac
