#!/bin/bash

mkdir -p $PREFIX/bin ${PREFIX}/share/pbptyper

# Copy wrapper
chmod 755 bin/pbptyper bin/pbptyper-bioconda
cp -f bin/pbptyper $PREFIX/bin/pbptyper-main
cp -f bin/pbptyper-bioconda $PREFIX/bin/pbptyper

# Copy schema (~100kb)
cp -f data/pbptyper.yaml ${PREFIX}/share/pbptyper
cp -f data/pbptyper.fasta ${PREFIX}/share/pbptyper
