#!/bin/bash

# copy scripts and its dependencies to $PREFIX/bin folder
mkdir -p ${PREFIX}/bin
cp -ar AlloSHP/lib \
    AlloSHP/utils \
    AlloSHP/sample_data \
    AlloSHP/WGA \
    AlloSHP/vcf2alignment \
    AlloSHP/vcf2synteny \
    pangenes/cpanfile \
    pangenes/Makefile \
    pangenes/version.txt \
    pangenes/README.md \
    LICENSE \
    ${PREFIX}/bin

make install
