#!/bin/bash

mkdir -p $PREFIX/bin ${PREFIX}/share/sccmec

# Copy wrapper
chmod 755 bin/sccmec-targets-bioconda
cp -f bin/sccmec-targets-bioconda $PREFIX/bin/sccmec-targets

chmod 755 bin/sccmec-regions-bioconda
cp -f bin/sccmec-regions-bioconda $PREFIX/bin/sccmec-regions

chmod 755 bin/sccmec bin/sccmec-bioconda
cp -f bin/sccmec $PREFIX/bin/sccmec-main
cp -f bin/sccmec-bioconda $PREFIX/bin/sccmec

# Copy schema (~100kb)
cp -f data/sccmec-targets.yaml ${PREFIX}/share/sccmec
cp -f data/sccmec-targets.fasta ${PREFIX}/share/sccmec
cp -f data/sccmec-regions.yaml ${PREFIX}/share/sccmec
cp -f data/sccmec-regions.fasta ${PREFIX}/share/sccmec
