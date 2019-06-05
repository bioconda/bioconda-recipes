#!/bin/sh

mkdir -p $PREFIX/bin

chmod +x src/*.py
cp samplot.py $PREFIX/bin
cp samplot_vcf.py $PREFIX/bin

