#!/bin/bash

mkdir -p $PREFIX/bin
pip install PyVCF==0.6.8
chmod 755 vcf-annotator.py
cp -f vcf-annotator.py $PREFIX/bin/vcf-annotator
