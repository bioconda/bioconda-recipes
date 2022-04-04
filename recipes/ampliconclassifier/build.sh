#!/bin/bash
set -eu -o pipefail
OUTDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/
mkdir -p $OUTDIR
mkdir -p $PREFIX/bin
cp amplicon_classifier.py amplicon_similarity.py ac_util.py get_genes.py radar_plotting.py patch_regions.tsv sorted_background_scores.txt $OUTDIR
ln -s $OUTDIR/amplicon_classifier.py $PREFIX/bin/amplicon_classifier.py
ln -s $OUTDIR/amplicon_similarity.py $PREFIX/bin/amplicon_similarity.py