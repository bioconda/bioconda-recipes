#!/bin/bash
mkdir -p $PREFIX/bin

cd inst/extcode/
export LD_LIBRARY_PATH="$PREFIX/lib"
${CXX} -std=c++11 -I$PREFIX/include -L$PREFIX/lib snp-pileup.cpp -lhts -o $PREFIX/bin/snp-pileup

$PREFIX/bin/snp-pileup --help
