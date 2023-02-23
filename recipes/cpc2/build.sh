#!/bin/bash
set -eu

mkdir -p ${PREFIX}/bin
chmod a+x bin/*
cp bin/* ${PREFIX}/bin/

mkdir -p ${PREFIX}/data
chmod a+tx data/*
cp data/* ${PREFIX}/data/

mkdir -p ${PREFIX}/libs/libsvm
chmod a+x libs/libsvm/*
cp libs/libsvm/* ${PREFIX}/libs/libsvm

cd ${PREFIX}/libs/libsvm
gzip -dc libsvm-3.18.tar.gz | tar xf -
cd libsvm-3.18
make clean && make
