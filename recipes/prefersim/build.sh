#!/bin/bash

mkdir -p $PREFIX/bin
$CC -g -o $PREFIX/bin/PReFerSim $LDFLAGS $CFLAGS PReFerSim.c -lm -lgsl -lgslcblas -O3
