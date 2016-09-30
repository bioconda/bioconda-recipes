#!/bin/bash

# tag v1.4 on github has everything as a single zip file, which also includes
# example data.
#

# Unzip and clean up
unzip Spectacle.zip
rm Spectacle.zip
mv Spectacle/* .
rm -r Spectacle

# Add #!/usr/bin/evn python to the wrapper script
patch -p0 -i $RECIPE_DIR/shebang.patch

# fix python wrapper to be py3 compatible
2to3 -w Spectacle_python.py

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

# We need the jarfile, python wrapper, and extra wrapper and downloading
# script. The first two come from the repo; the second two are specific to this
# recipe.
cp Spectacle.jar $outdir/
cp Spectacle_python.py $outdir/
cp $RECIPE_DIR/Spectacle.sh $outdir/
cp $RECIPE_DIR/download_spectacle_data.sh $outdir/

chmod +x $outdir/Spectacle.sh
chmod +x $outdir/Spectacle_python.py
chmod +x $outdir/download_spectacle_data.sh

ln -s $outdir/Spectacle.sh $PREFIX/bin
ln -s $outdir/Spectacle_python.py $PREFIX/bin
ln -s $outdir/download_spectacle_data.sh $PREFIX/bin

# clean up data files
rm -r ANCHORFILES CHROMSIZES COORDS SAMPLEDATA_HG19 SAMPLEDATA_HG18 OUTPUTSAMPLE_HG19
rm hg19_inputfilelist.txt
rm hg19_inputfilelist1.txt
rm hg19_cellmarkfiletable.txt
