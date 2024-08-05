#!/bin/bash

mkdir -p $PREFIX/bin ${PREFIX}/share/sccmec

# Copy wrapper
chmod 755 bin/sccmec-bioconda
cp -f bin/sccmec-bioconda $PREFIX/bin/sccmec

# Copy schema (~100kb)
cp -f data/sccmec.yaml ${PREFIX}/share/sccmec
cp -f data/sccmec.fasta ${PREFIX}/share/sccmec
