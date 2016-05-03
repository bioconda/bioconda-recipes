#!/bin/bash
set -eu

sed -i.bak '1i#!/opt/anaconda1anaconda2anaconda3/bin/python' vcf2db.py
chmod a+x vcf2db.py
mkdir -p $PREFIX/bin
cp vcf2db.py $PREFIX/bin
