#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $outdir
mkdir -p $PREFIX/bin

# We need the jarfile (provided by the source), wrapper (provided by this
# recipe) and data download script (provided by this recipe)
cp ChromHMM.jar $outdir/

for fn in ChromHMM.sh download_chromhmm_data.sh; do
  dest=$outdir/$fn
  cp $RECIPE_DIR/$fn $dest
  chmod +x $dest
  ln -s $dest $PREFIX/bin
done
