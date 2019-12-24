#!/bin/bash

RSAT_DEST="$PREFIX/opt/rsat/"
mkdir -p "$RSAT_DEST"
mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/share/rsat"

cp -a LICENSE.txt perl-scripts python-scripts makefiles R-scripts "$RSAT_DEST"
cp bin/rsat $PREFIX/bin/rsat
cp share/rsat/rsat.yaml $PREFIX/share/rsat/rsat.yaml

## Add relative links from share/rsat to the actual folders to enable rsat command to run the subcommands
cd $PREFIX/share/rsat
ln -s ../../opt/rsat/perl-scripts .
ln -s ../../opt/rsat/python-scripts .
ln -s ../../bin .

# Build and dispatch compiled binaries
cd contrib
for dbin in info-gibbs count-words matrix-scan-quick retrieve-variation-seq variation-scan 
do
    cd "$dbin"
    make clean && make CC=$CC CXX=$CXX && cp "$dbin" "$PREFIX/bin"
    cd ..
done
cd ..

# Build the R package with RSAT functions used by matrix-clustering
cd R-scripts
R CMD INSTALL --no-multiarch --with-keep.source TFBMclust
cd ..
