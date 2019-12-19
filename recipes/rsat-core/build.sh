#!/bin/bash

RSAT_DEST="$PREFIX/opt/rsat/"
mkdir -p "$RSAT_DEST"

cp -a perl-scripts python-scripts makefiles share/rsat/rsat.yaml "$RSAT_DEST"
cp bin/rsat $PREFIX/bin/rsat

# Build and dispatch compiled binaries
# cd contrib
for dbin in info-gibbs 
# TEMPORARILY COMMENTED count-words matrix-scan-quick retrieve-variation-seq variation-scan 
do
    if [ -d "$dbin" ]; then
        cd "$dbin"
        make clean && make CC=$CC CXX=$CXX && cp "$dbin" "$PREFIX/bin"
        cd ..
    fi
done


# TODO: R packaging
# JvH note: I will do this as soon as the previous steps are working
