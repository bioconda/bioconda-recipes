#!/bin/bash

mkdir -p $PREFIX/bin
chmod 755 vcf-annotator.py
cp -f vcf-annotator.py $PREFIX/bin/vcf-annotator
