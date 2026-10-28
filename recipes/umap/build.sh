#!/bin/bash

chmod +x umap/combine_umaps.py umap/get_kmers.py umap/handle_fasta.py umap/map_bed.py umap/run_bowtie.py umap/ubismap.py umap/uint8_to_bed.py umap/uint8_to_bed_parallel.py umap/unify_bowtie.py

# copy scripts
cp umap/*.py ${PREFIX}/bin
