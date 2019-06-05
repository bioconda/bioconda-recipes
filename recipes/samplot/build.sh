#!/bin/sh

mkdir -p $PREFIX/bin

chmod +x src/*.py
cp src/samplot.py $PREFIX/bin
cp src/samplot_vcf.py $PREFIX/bin

