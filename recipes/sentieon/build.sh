#!/bin/bash
set -eu

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done

cp -r * $outdir

sed -i.bak s#!/bin/sh#!/bin/bash# $outdir/bin/sentieon
ln -s $outdir/bin/sentieon $PREFIX/bin/sentieon
ln -s $outdir/bin/bwa $PREFIX/bin/sentieon-bwa
