#!/bin/bash

mkdir -p $PREFIX/bin

cd FCP
cp *.py $PREFIX/bin

cd nb-train-src
make
cp nb-train $PREFIX/bin
cd ../

cd nb-classify-src
make
cp nb-classify $PREFIX/bin
cd ../