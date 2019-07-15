#!/bin/bash
cd src
make
mkdir -p $PREFIX/bin
cp multi_motif_sampler $PREFIX/bin
