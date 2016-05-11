#!/bin/bash
set -eu -o pipefail

sharedir=$PREFIX/share
outdir=$sharedir/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

unamestr=`uname`
if [ "$unamestr" == 'Linux' ];
then
    cp -R $SRC_DIR/* $sharedir
    # Provide a link to the Linux executable from $PREFIX/bin.
    ln -s $sharedir/ImageJ-linux64 $PREFIX/bin/ImageJ-linux64
elif [ "$unamestr" == 'Darwin' ];
then
    hdiutil attach fiji-macosx-20141125.dmg
    cp -R /Volumes/Fiji/Fiji.app/ $sharedir
    hdiutil detach /Volumes/Fiji
    # Eliminate problematic java3d for osx since we do not use it anyway.
    rm -rf $sharedir/java
    if [[ `sw_vers -productVersion | tr -d '.'` -ge 1010 ]];
    then
        # The ImageJ launcher contained in this version of Fiji will not
        # run on Yosemite or newer OS versions due to some operating system
        # change, so apply the patched version of the ImageJ launcher.
        cp $RECIPE_DIR/ImageJ-macosx $sharedir/Contents/MacOS/ImageJ-macosx
        # Remove the old ImageJ launcher for tiger.
        rm $sharedir/Contents/MacOS/ImageJ-tiger
        # Provide a link to the osx executable from $PREFIX/bin.
        ln -s $sharedir/Contents/MacOS/ImageJ-macosx $PREFIX/bin/ImageJ-macosx
    else
        # Provide a link to the osx executable from $PREFIX/bin.
        ln -s $sharedir/Contents/MacOS/ImageJ-tiger $PREFIX/bin/ImageJ-tiger
    fi
fi

cp $RECIPE_DIR/fiji.sh $outdir/fiji
ln -s $outdir/fiji $PREFIX/bin
chmod 0755 "${PREFIX}/bin/fiji"
