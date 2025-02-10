#!/bin/bash

# Create bin directory if necessary
mkdir -p $PREFIX/bin

# Copy executable and required data files to bin directory
cp gofigure.py $PREFIX/bin/
cp data/ic.tsv $PREFIX/bin/
cp data/go.obo $PREFIX/bin/
cp data/relations_full.tsv $PREFIX/bin/

chmod +x $PREFIX/bin/gofigure.py
