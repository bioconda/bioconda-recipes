#!/usr/bin/env bash

# Main program
mv uropa.py $PREFIX/bin

mkdir -p $PREFIX/bin/uropa
mv uropa/* $PREFIX/bin/uropa

# Auxillary scripts
mv summary.R $PREFIX/bin
mv reformat_output.R $PREFIX/bin
mv utils/uropa2gtf.R $PREFIX/bin
