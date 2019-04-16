#!/bin/bash
mkdir -p $PREFIX/bin

cd inst/extcode/
${CXX} -std=c++11 -I$PREFIX/include -L$PREFIX/lib snp-pileup.cpp -lhts -o snp-pileup

./snp-pileup --help
cp snp-pileup $PREFIX/bin/
