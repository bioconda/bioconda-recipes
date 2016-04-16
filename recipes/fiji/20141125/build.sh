#!/bin/bash
set -eu -o pipefail

unamestr=`uname`
if [ "$unamestr" == 'Linux' ];
then
    cp -R $SRC_DIR/* $PREFIX
#elif [ "$unamestr" == 'Darwin' ];
#then
#    export DYLD_LIBRARY_PATH=$PREFIX/lib
#    hdiutil attach fiji-macosx-20141125.dmg
#    cp -R /Volumes/Fiji/Fiji.app/ $PREFIX
#    hdiutil detach /Volumes/Fiji
#    if [[ `sw_vers -productVersion | tr -d '.'` -ge 1010 ]];
#    then
#        # The ImageJ launcher contained in this version of Fiji will not
#        # run on Yosemite or newer OS versions due to some operating system
#        # change, so apply the patched version of the ImageJ launcher.
#        cp $RECIPE_DIR/ImageJ-macosx $PREFIX/Contents/MacOS/ImageJ-macosx
#        # Remove the old ImageJ launcher for tiger.
#        rm $PREFIX/Contents/MacOS/ImageJ-tiger
#    fi
fi

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp $RECIPE_DIR/fiji.sh $outdir/fiji
ln -s $outdir/fiji $PREFIX/bin
chmod 0755 "${PREFIX}/bin/fiji"
