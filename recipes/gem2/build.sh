#!/bin/bash

mkdir -p $PREFIX/bin
for file in gem-2-gem gem-2-sam gem-indexer \
    gem-indexer_bwt-dna gem-indexer_fasta2meta+cont \
    gem-indexer_generate gem-info gem-mappability \
    gem-mappability-retriever gem-mapper \
    gem-retriever gem-2-bed; do
    cp $file $PREFIX/bin/
    chmod +x $PREFIX/bin/$file
done
