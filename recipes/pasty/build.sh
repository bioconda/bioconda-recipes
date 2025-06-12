#!/bin/bash

mkdir -p $PREFIX/bin ${PREFIX}/share/pasty

# Copy wrapper
chmod 755 bin/pasty-bioconda
cp -f bin/pasty-bioconda $PREFIX/bin/pasty

# Copy schema (~100kb)
cp -f data/pa-osa.fasta ${PREFIX}/share/pasty
cp -f data/pa-osa.yaml ${PREFIX}/share/pasty
