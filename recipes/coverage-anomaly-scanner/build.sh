#!/bin/sh

git submodule init
git submodule update

mkdir -p build

make print CXX=${CXX}

mkdir -p ${PREFIX}/bin

cp cas ${PREFIX}/bin
