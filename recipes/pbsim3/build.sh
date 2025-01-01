#!/bin/bash

set -eux -o pipefail

outdir=$PREFIX/data
mkdir -p $outdir
cp -R ./data/* $outdir/

autoreconf -fi
./configure --prefix="${PREFIX}"
make
make install
