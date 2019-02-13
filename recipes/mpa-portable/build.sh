#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/mpa-portable.py $outdir/mpa-portable
ln -s $outdir/mpa-portable $PREFIX/bin
chmod 0755 "${PREFIX}/bin/mpa-portable"
if [ -f $outdir/built/Comet/linux/comet.exe ] ; then chmod 0755 $outdir/built/Comet/linux/comet.exe ; fi
if [ -f $outdir/built/X!Tandem/linux/linux_64bit/tandem ] ; then chmod 0755 $outdir/built/X!Tandem/linux/linux_64bit/tandem ; fi
if [ -f $outdir/built/X!Tandem/linux/linux_32bit/tandem ] ; then chmod 0755 $outdir/built/X!Tandem/linux/linux_32bit/tandem ; fi
