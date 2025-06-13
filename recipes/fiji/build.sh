#!/bin/bash
set -xeu -o pipefail

sharedir=$PREFIX/share
outdir=$sharedir/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

UNAME_S=$(uname -s)
UNAME_M=$(uname -m)
cp -R $SRC_DIR/* $sharedir

# Make a symlink to get a single executable name
# for both arch
if [ "${UNAME_S}" == 'Linux' ];
then
    # Provide a link to the Linux executable from $PREFIX/bin.
    if [ "${UNAME_M}" == 'x86_64' ];
    then
        ln -s $sharedir/ImageJ-linux64 $PREFIX/bin/ImageJ_bin
    elif [ "${UNAME_M}" == 'aarch64' ];
    then
        ln -s $sharedir/fiji-linux-arm64 $PREFIX/bin/ImageJ_bin
    fi
elif [ "${UNAME_S}" == 'Darwin' ];
then
    # Provide a link to the osx executable from $PREFIX/bin.
    ln -s $sharedir/Contents/MacOS/ImageJ-macosx $PREFIX/bin/ImageJ_bin
fi
# Change it to executable
chmod 0755 "${PREFIX}/bin/ImageJ_bin"

# Copy the ImageJ from the recipe which includes a set of userprefs
cp $RECIPE_DIR/ImageJ.sh $outdir/ImageJ
ln -s $outdir/ImageJ "${PREFIX}/bin"
chmod 0755 "${PREFIX}/bin/ImageJ"

# Copy bunwarpj and make it executable
cp $RECIPE_DIR/bunwarpj.sh $outdir/bunwarpj
ln -s $outdir/bunwarpj $PREFIX/bin
chmod 0755 "${PREFIX}/bin/bunwarpj"
