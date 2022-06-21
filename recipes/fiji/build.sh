#!/bin/bash
set -eu -o pipefail

sharedir=$PREFIX/share
outdir=$sharedir/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

unamestr=`uname`
cp -R $SRC_DIR/* $sharedir
if [ "$unamestr" == 'Linux' ];
then
    # Provide a link to the Linux executable from $PREFIX/bin.
    ln -s $sharedir/ImageJ-linux64 $PREFIX/bin/ImageJ
elif [ "$unamestr" == 'Darwin' ];
then
    # Provide a link to the osx executable from $PREFIX/bin.
    ln -s $sharedir/Contents/MacOS/ImageJ-macosx $PREFIX/bin/ImageJ
fi

cp $RECIPE_DIR/bunwarpj.sh $outdir/bunwarpj
ln -s $outdir/bunwarpj $PREFIX/bin
chmod 0755 "${PREFIX}/bin/bunwarpj"
chmod 0755 "${PREFIX}/bin/ImageJ"

chmod +x "${PREFIX}/bin/ImageJ"
chmod +x "${PREFIX}/bin/bunwarpj"
