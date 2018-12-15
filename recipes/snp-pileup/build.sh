#!/bin/bash

mkdir -p $PREFIX/bin

cd inst/extcode/
g++ -std=c++11 snp-pileup.cpp -lhts -o snp-pileup
chmod a+x snp-pileup
mv snp-pileup $PREFIX/bin/
