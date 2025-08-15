#!/bin/bash

# Build index
samtools faidx shigatyper/resources/ShigellaRef5.fasta
minimap2 -d shigatyper/resources/ShigellaRef5.mmi shigatyper/resources/ShigellaRef5.fasta

# ShigaTyper
$PYTHON -m pip install --no-deps --ignore-installed -vv .
