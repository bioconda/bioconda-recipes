#!/bin/bash
outdir=$PREFIX/data
mkdir -p $outdir
cp -R ./data/* $outdir/
./configure --prefix="${PREFIX}"
make
make install
