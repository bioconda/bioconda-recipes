#!/bin/bash
cd src
make CPP="$GXX -O3 -fopenmp"
mkdir -p $PREFIX/bin
cp multi_motif_sampler $PREFIX/bin
