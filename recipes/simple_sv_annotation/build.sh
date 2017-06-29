#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

sed -i.bak 's#!/usr/bin/env python#!/opt/anaconda1anaconda2anaconda3/bin/python#' simple_sv_annotation.py
cp simple_sv_annotation.py $outdir
cp *.txt $outdir
chmod a+x $outdir/simple_sv_annotation.py
ln -s $outdir/simple_sv_annotation.py $PREFIX/bin
