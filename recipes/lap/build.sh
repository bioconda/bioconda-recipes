#!/bin/bash

mkdir -p $PREFIX/bin

cd src
cp aligner/*.py $PREFIX/bin

cd dynamic
make
cp mean $PREFIX/bin
cp probability $PREFIX/bin
cp mprobability $PREFIX/bin
cp sample $PREFIX/bin
cp stitch $PREFIX/bin
