#!/bin/bash
mkdir -p $PREFIX/bin
sed -i.bak 's#!/usr/bin/env python#!/opt/anaconda1anaconda2anaconda3/bin/python#' gvcf_regions.py
chmod a+x gvcf_regions.py
cp gvcf_regions.py $PREFIX/bin
