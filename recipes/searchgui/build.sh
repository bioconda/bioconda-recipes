#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/searchgui.py $outdir/searchgui
ls -l $outdir
ln -s $outdir/searchgui $PREFIX/bin
chmod 0755 "${PREFIX}/bin/searchgui"

# removing xtandem prebuilt binaries and replacing them by xtandem package ones
rm -f "$outdir"'/resources/XTandem/linux/linux_64bit/tandem'
ln -sf "$(which xtandem)" "$outdir"'/resources/XTandem/linux/linux_64bit/tandem'
