#!/bin/bash

BIN=$PREFIX/bin
mkdir -p $BIN
cp deconvolve.py $BIN
sed -i '1s/^/#!\/usr\/bin\/env Rscript\n/' process_array.R
cp process_array.R $BIN
cp ref_sample.RData $BIN
