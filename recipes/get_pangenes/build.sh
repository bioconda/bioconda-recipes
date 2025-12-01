#!/bin/bash

# copy scripts and its dependencies to $PREFIX/bin folder
mkdir -p ${PREFIX}/bin
cp -ar pangenes/bin \
    pangenes/lib \
    pangenes/get_pangenes.pl \
    pangenes/_cut_sequences.pl \
    pangenes/_collinear_genes.pl \
    pangenes/_cluster_analysis.pl \
    pangenes/check_evidence.pl \
    pangenes/_dotplot.pl \
    pangenes/match_cluster.pl \
    pangenes/rename_pangenes.pl \
    pangenes/HPC* \
    pangenes/CHANGES.txt \
    pangenes/README.md \
    LICENSE \
    ${PREFIX}/bin
