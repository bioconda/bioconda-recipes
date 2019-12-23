#!/bin/bash

RSAT_DEST="$PREFIX/opt/rsat/"
mkdir -p "$RSAT_DEST"
mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/share/rsat"

cp -a LICENSE.txt perl-scripts python-scripts makefiles R-scripts "$RSAT_DEST"
cp bin/rsat $PREFIX/bin/rsat
cp share/rsat/rsat.yaml $PREFIX/share/rsat/rsat.yaml



# Build and dispatch compiled binaries
cd contrib
for dbin in info-gibbs count-words matrix-scan-quick retrieve-variation-seq variation-scan 
do
    cd "$dbin"
    make clean && make CC=$CC CXX=$CXX && cp "$dbin" "$PREFIX/bin"
    cd ..
done
cd ..

## TEMPORARIY COMMENTED BECAUSE GENERATES ERROR
##      R: command not found
# # Build the R package with RSAT functions used by matrix-clustering
# cd R-scripts
# R CMD INSTALL --no-multiarch --with-keep.source TFBMclust
# cd ..
