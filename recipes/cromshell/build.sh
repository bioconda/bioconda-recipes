#!/bin/bash

set -eu -o pipefail

mkdir -p $PREFIX/bin
cp cromshell $PREFIX/bin/

outdir=$PREFIX/share/$PKG_NAME
mkdir -p $outdir
cp README.md $outdir/


