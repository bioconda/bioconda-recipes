#!/bin/bash

mkdir -p $PREFIX/bin

make HDF5= EIGEN=
cp nanopolish $PREFIX/bin
cp scripts/nanopolish_makerange.py $PREFIX/bin
cp scripts/nanopolish_merge.py $PREFIX/bin
cp scripts/dropmodel.py  $PREFIX/bin
# cp scripts/consensus-preprocess.pl $PREFIX/bin # Skipping this pre-processing step at the moment. 

