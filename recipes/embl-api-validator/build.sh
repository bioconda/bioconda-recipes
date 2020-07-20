#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp *.jar ${outdir}

cp $RECIPE_DIR/embl-api-validator.py $outdir/embl-api-validator

ls -l $outdir
ln -s $outdir/embl-api-validator $PREFIX/bin
chmod 0755 "${PREFIX}/bin/embl-api-validator"
