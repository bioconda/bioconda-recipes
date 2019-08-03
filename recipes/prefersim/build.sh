#!/bin/bash

mkdir -p $PREFIX/bin
$CC -g -o $PREFIX/bin/PReFerSim PReFerSim.c -lm -lgsl -lgslcblas -O3
