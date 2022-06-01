#!/bin/bash

# ShigaTyper
$PYTHON -m pip install --no-deps --ignore-installed -vv .

# Run single genome to build index
minimap2 -d shigatyper/resources/ShigellaRef5.mmi shigatyper/resources/ShigellaRef5.fasta
