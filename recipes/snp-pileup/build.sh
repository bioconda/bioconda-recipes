#!/bin/bash
mkdir -p $PREFIX/bin

cd inst/extcode/
${CXX} -std=c++11 -I$PREFIX/include -I `pwd`/htslib/include snp-pileup.cpp \
    -L$PREFIX/lib -L `pwd`/htslib/lib \
    -lhts -o snp-pileup -lcurl -lz -lpthread -lcrypto -llzma -lbz2

./snp-pileup --help
cp snp-pileup $PREFIX/bin/
