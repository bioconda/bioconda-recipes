#!/bin/bash
OUTDIR=$PREFIX/share/dkfz-bias-filter
mkdir -p $OUTDIR
cp -r scripts/* $OUTDIR

for file in biasFilter.py dkfzbiasfilter_summarize.py
do
    chmod a+x $OUTDIR/$file
    sed -i.bak 's#!/usr/bin/env python#!/opt/anaconda1anaconda2anaconda3/bin/python#' $OUTDIR/$file
    rm -f $OUTDIR/$file.bak
done

mkdir -p $PREFIX/bin
ln -s $OUTDIR/biasFilter.py $PREFIX/bin/dkfzbiasfilter.py
ln -s $OUTDIR/dkfzbiasfilter_summarize.py $PREFIX/bin/dkfzbiasfilter_summarize.py
