#!/bin/bash

function install_htslib(){
    # Download and install htslib. Compiled stuff is in `pwd`/htslib
    pushd .
    rm -f htslib-1.8.tar.bz2
    wget https://github.com/samtools/htslib/releases/download/1.8/htslib-1.8.tar.bz2
    tar xf htslib-1.8.tar.bz2
    rm htslib-1.8.tar.bz2
    mv htslib-1.8 htslib
    cd htslib
    ./configure --prefix=`pwd`
    make -j 4
    make install
    popd
}

mkdir -p $PREFIX/bin

cd inst/extcode/

install_htslib

ln -s `pwd`/htslib/lib/libhts.a `pwd`/htslib/lib/libhts-static.a
g++ -std=c++11 -I$PREFIX/include -I `pwd`/htslib/include snp-pileup.cpp \
    -L$PREFIX/lib -L `pwd`/htslib/lib \
    -lhts-static -o snp-pileup -lcurl -lz -lpthread -lcrypto -llzma -lbz2

./snp-pileup --help
cp snp-pileup $PREFIX/bin/
