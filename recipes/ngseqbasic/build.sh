#!/bin/bash
set -eu -o pipefail

# for reference, see
# https://github.com/bioconda/bioconda-recipes/issues/3780
# https://github.com/bioconda/bioconda-recipes/blob/master/recipes/weblogo/build.sh

# create destination folder
OUTDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $OUTDIR

# install folders
cp -r $SRC_DIR/bin $OUTDIR
cp -r $SRC_DIR/README $OUTDIR
cp -r $SRC_DIR/conf $OUTDIR

# install files
chmod +x $SRC_DIR/testEnvironment.sh
chmod +x $SRC_DIR/NGseqBasic.sh
cp $SRC_DIR/testEnvironment.sh $OUTDIR
cp $SRC_DIR/NGseqBasic.sh $OUTDIR

# create executables
BINDIR=$PREFIX/bin
mkdir -p $BINDIR

NGseqBasic=$BINDIR/NGseqBasic
echo "#! /bin/bash" > $NGseqBasic;
echo 'DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )' >>  $NGseqBasic;
echo '$DIR/../share/'$(basename $OUTDIR)/NGseqBasic.sh '$@' >> $NGseqBasic;
chmod +x $NGseqBasic

testEnvironment=$BINDIR/testEnvironment
echo "#! /bin/bash" > $testEnvironment;
echo 'DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )' >>  $testEnvironment;
echo '$DIR/../share/'$(basename $OUTDIR)/testEnvironment.sh '$@' >> $testEnvironment;
chmod +x $testEnvironment

