#!/bin/sh

git submodule init
git submodule update

make -C htslib CC=${CC}

mkdir -p build
make print CXX=${CXX}

mkdir -p ${PREFIX}/bin
cp cas ${PREFIX}/bin
