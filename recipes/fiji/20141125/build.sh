#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

unamestr=`uname`
if [ "$unamestr" == 'Linux' ];
then
    cp -R $SRC_DIR/* $PREFIX
    # Provide a link to the Linux executable from $PREFIX/bin.
    # ln -s $PREFIX/ImageJ-linux32 $PREFIX/bin/ImageJ-linux32
    ln -s $PREFIX/ImageJ-linux64 $PREFIX/bin/ImageJ-linux64
elif [ "$unamestr" == 'Darwin' ];
then
    hdiutil attach fiji-macosx-20141125.dmg
    cp -R /Volumes/Fiji/Fiji.app/ $PREFIX
    hdiutil detach /Volumes/Fiji
    # Eliminate problematic java3d for osx since we do not use it anyway.
    rm -rf $PREFIX/java
    if [[ `sw_vers -productVersion | tr -d '.'` -ge 1010 ]];
    then
        # The ImageJ launcher contained in this version of Fiji will not
        # run on Yosemite or newer OS versions due to some operating system
        # change, so apply the patched version of the ImageJ launcher.
        cp $RECIPE_DIR/ImageJ-macosx $PREFIX/Contents/MacOS/ImageJ-macosx
        # Remove the old ImageJ launcher for tiger.
        rm $PREFIX/Contents/MacOS/ImageJ-tiger
        # Provide a link to the osx executable from the installation dir.
        ln -s $PREFIX/Contents/MacOS/ImageJ-macosx $PREFIX/ImageJ-macosx
        # Provide a link to the osx executable from $PREFIX/bin.
        ln -s $PREFIX/Contents/MacOS/ImageJ-macosx $PREFIX/bin/ImageJ-macosx
    else
        # Provide a link to the osx executable from the installation dir.
        ln -s $PREFIX/Contents/MacOS/ImageJ-tiger $PREFIX/ImageJ-tiger
        # Provide a link to the osx executable from $PREFIX/bin.
        ln -s $PREFIX/Contents/MacOS/ImageJ-tiger $PREFIX/bin/ImageJ-tiger
    fi
fi

cp $RECIPE_DIR/fiji.sh $outdir/fiji
ln -s $outdir/fiji $PREFIX/bin
chmod 0755 "${PREFIX}/bin/fiji"
