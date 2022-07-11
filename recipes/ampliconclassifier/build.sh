#!/bin/bash
set -eu -o pipefail
OUTDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/
mkdir -p $OUTDIR
mkdir -p $OUTDIR/resources
mkdir -p $PREFIX/bin
cp amplicon_classifier.py amplicon_similarity.py ac_util.py get_genes.py radar_plotting.py  amplicons_intersecting_bed.py make_results_table.py softlink_images.py feature_similarity.py $OUTDIR

cp resources/oncogene_list_ONGene.txt resources/patch_regions.tsv resources/sorted_background_scores.txt $OUTDIR/resources/

ln -s $OUTDIR/amplicon_similarity.py $PREFIX/bin/amplicon_similarity.py
ln -s $OUTDIR/amplicons_intersecting_bed.py $PREFIX/bin/amplicons_intersecting_bed.py
ln -s $OUTDIR/feature_similarity.py $PREFIX/bin/feature_similarity.py
ln -s $OUTDIR/make_input.sh $PREFIX/bin/make_input.sh
ln -s $OUTDIR/make_results_table.py $PREFIX/bin/make_results_table.py
ln -s $OUTDIR/softlink_images.py $PREFIX/bin/softlink_images.py