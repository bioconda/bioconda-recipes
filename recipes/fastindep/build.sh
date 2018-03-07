#!/bin/bash

g++ -Wall -o fastindep -O main.cpp DataMethods.cpp
g++ -Wall -o fastindep-symmetry -O check_symm.cpp

mkdir -p ${PREFIX}/bin
cp fastindep ${PREFIX}/bin
cp fastindep-symmetry ${PREFIX}/bin
