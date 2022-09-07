#!/bin/bash

cd src
make CXX=$CXX

mkdir -p $PREFIX/bin
cp SELAM SELAM_STATS $PREFIX/bin 
