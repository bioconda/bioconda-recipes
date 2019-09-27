#!/bin/sh

mkdir -p $PREFIX/bin

sed -i '1s/^/#!\/usr\/bin\/env python\n/' src/samplot_vcf.py
chmod +x src/*.py

cp src/samplot.py $PREFIX/bin
cp src/samplot_vcf.py $PREFIX/bin

