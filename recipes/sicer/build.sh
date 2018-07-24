#!/bin/bash
set -eu -o pipefail

# for reference, see
# https://github.com/bioconda/bioconda-recipes/issues/3780
# https://github.com/bioconda/bioconda-recipes/blob/master/recipes/weblogo/build.sh

# create destination folder
OUTDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $OUTDIR

# install folders
cp -r $SRC_DIR/SICER $OUTDIR

# install files
for b in `echo SICER.sh SICER-rb.sh SICER-df.sh SICER-df-rb.sh` ;
do
    sed -i'' -e "s|PATHTO=.*|PATHTO=$OUTDIR|g" $SRC_DIR/SICER/$b
    chmod +x $SRC_DIR/SICER/$b
    cp $SRC_DIR/SICER/$b $OUTDIR
done

# create executables
BINDIR=$PREFIX/bin
mkdir -p $BINDIR

for b in `echo SICER.sh SICER-rb.sh SICER-df.sh SICER-df-rb.sh` ;
do
    BinFile=$BINDIR/$b
    echo "#! /bin/bash" > $BinFile;
    echo 'DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )' >>  $BinFile;
    echo '$DIR/../share/'$(basename $OUTDIR)/$b '$@' >> $BinFile;
    chmod +x $BinFile
done

