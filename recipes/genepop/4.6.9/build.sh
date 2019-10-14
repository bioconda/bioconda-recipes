#!/bin/bash

cd src
g++ -DNO_MODULES -o Genepop GenepopS.cpp -O3

mkdir -p $PREFIX/bin
cp Genepop $PREFIX/bin
