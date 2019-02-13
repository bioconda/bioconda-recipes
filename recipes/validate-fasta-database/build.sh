#!/bin/bash

JAVA_PROJECT_VERSION=1.0

set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

# copy jar to to outdir/
jarfile="validate_fasta_database-$JAVA_PROJECT_VERSION.jar"
cp $jarfile $outdir

cp $RECIPE_DIR/validate-fasta-database.py $outdir/validate-fasta-database
ls -l $outdir
ln -s $outdir/validate-fasta-database $PREFIX/bin
chmod 0755 "${PREFIX}/bin/validate-fasta-database"
