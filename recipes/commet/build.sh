#!/bin/bash

mkdir -p ${PREFIX}/bin

# installation
make

# copy binaries and scripts
cp Commet.py ${PREFIX}/bin
cp dendro.R ${PREFIX}/bin
cp heatmap.r ${PREFIX}/bin
cp bin/* ${PREFIX}/bin
