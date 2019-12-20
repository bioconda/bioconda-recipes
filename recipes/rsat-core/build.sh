#!/bin/bash

RSAT_DEST="$PREFIX/opt/rsat/"
mkdir -p "$RSAT_DEST"
mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/share/rsat"

cp -a LICENSE.txt perl-scripts python-scripts makefiles R-scripts "$RSAT_DEST"
cp bin/rsat $PREFIX/bin/rsat
cp share/rsat/rsat.yaml $PREFIX/share/rsat/rsat.yaml

# Build and dispatch compiled binaries
# cd contrib
for dbin in info-gibbs count-words matrix-scan-quick retrieve-variation-seq variation-scan 
do
    if [ -d "$dbin" ]; then
        cd "$dbin"
        make clean && make CC=$CC CXX=$CXX && cp "$dbin" "$PREFIX/bin"
        cd ..
    fi
done


# TODO: R packaging
# JvH note: I will do this as soon as the previous steps are working
