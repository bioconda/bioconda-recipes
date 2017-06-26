#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#
set -o nounset -o pipefail -o errexit
set -o xtrace

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
echo "test.sh outdir: "$outdir

echo "PREFIX: "$PREFIX
echo "PKG_NAME "$PKG_NAME
echo "PKG_VERSION "$PKG_VERSION
echo "PKG_BUILDNUM "$PKG_BUILDNUM
echo "RECIPE_DIR "$RECIPE_DIR
echo "SRC_DIR "$SRC_DIR

ls $SRC_DIR/bin
cd $SRC_DIR/bin



./project.sh ../data/pressto_BLOOD_enhancers.bed DEFAULT_EQ DEFAULT_ET

./project.sh ../data/vista_LIMB_sorted.bed DEFAULT_EQ DEFAULT_ET