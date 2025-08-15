#!/bin/bash

set -eux -o pipefail

outdir=$PREFIX/data
mkdir -p $outdir
cp -R ./data/* $outdir/

export M4="${BUILD_PREFIX}/bin/m4"

autoreconf -fi
./configure --prefix="${PREFIX}"
make -j"${CPU_COUNT}"
make install
