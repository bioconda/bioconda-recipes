#!/bin/bash

mkdir -p $PREFIX/bin
chmod 755 bin/vcf-annotator.py
cp -f bin/vcf-annotator.py $PREFIX/bin/vcf-annotator
