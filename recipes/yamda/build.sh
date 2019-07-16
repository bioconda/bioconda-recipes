#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir

chmod +x run_em.py erase_annoying_sequences.py
cp -r * $outdir/
ln -s $outdir/run_em.py $PREFIX/bin/
ln -s $outdir/erase_annoying_sequences.py $PREFIX/bin/
