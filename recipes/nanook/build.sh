#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R dist/* $outdir/
cp $RECIPE_DIR/nanook.py $outdir/nanook
ls -l $outdir
ln -s $outdir/nanook $PREFIX/bin
chmod 0755 "${PREFIX}/bin/nanook"

export NANOOK_DIR=$outdir

binaries="\
nanook_get_read_stats.pl
nanook_get_tracking.pl
nanook_plot_comparison.R
nanook_plot_comparison_reference.R
nanook_plot_lengths.R
nanook_plot_reference.R
nanook_split_fasta
"

for i in $binaries; do cp $SRC_DIR/bin/$i $outdir/$i && chmod a+x $outdir/$i && ln -s $outdir/$i $PREFIX/bin/$i; done

