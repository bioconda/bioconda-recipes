#!/bin/sh
set -x -e

cd src/grf-main
gcc main.cpp DetectMITE.h DetectMITE.cpp DetectIR.h DetectIR.cpp functions.h functions.cpp -std=c++11 -fopenmp -O3 -o grf-main

for name in bin/* ; do
  ln -s $name ${PREFIX}/bin/$(basename $name)
done
