#!/bin/bash
cd src
make CC="$CC -O3 -fopenmp"
mkdir -p $PREFIX/bin
cp multi_motif_sampler $PREFIX/bin
