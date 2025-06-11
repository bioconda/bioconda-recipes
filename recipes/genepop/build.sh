#!/bin/bash

set -xe

cd src
${CXX} -DNO_MODULES -o Genepop GenepopS.cpp -O3 -std=c++11

mkdir -p $PREFIX/bin
cp Genepop $PREFIX/bin
chmod 0755 $PREFIX/bin/Genepop
