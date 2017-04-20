#!/bin/bash

mkdir -p $PREFIX/bin

cd src
cp aligner/*.py $PREFIX/bin

cd dynamic
make
cp mean $PREFIX/bin
cp mean probability
cp mean mprobability
cp mean sample
cp mean stitch