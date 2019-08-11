#!/bin/bash

mkdir -p $PREFIX/bin
$CC -g -o $PREFIX/bin/PReFerSim -I${PREFIX}/include -L${PREFIX}/lib PReFerSim.c -lm -lgsl -lgslcblas -O3
