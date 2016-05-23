#!/bin/bash
mkdir -p $PREFIX/bin
sed -i '1i#!/opt/anaconda1anaconda2anaconda3/bin/python' gvcf_regions.py
chmod a+x gvcf_regions.py
cp gvcf_regions.py $PREFIX/bin
