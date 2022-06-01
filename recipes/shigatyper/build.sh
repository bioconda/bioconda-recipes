#!/bin/bash

# Build index
minimap2 -d shigatyper/resources/ShigellaRef5.mmi shigatyper/resources/ShigellaRef5.fasta

# ShigaTyper
$PYTHON -m pip install --no-deps --ignore-installed -vv .
