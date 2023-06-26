#!/bin/bash
BINARY_HOME=$PREFIX/bin 
RAP_GREEN_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

# Copy source to the conda environment
mkdir -p $RAP_GREEN_HOME
cp -R $SRC_DIR/* $RAP_GREEN_HOME/

# Create symbolic links for a5_miseq's launch script
mkdir -p $BINARY_HOME
ln -s $RAP_GREEN_HOME/bin/RapGreen.jar $BINARY_HOME/ 





#Old script

#outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
#mkdir -p $outdir
#mkdir -p $PREFIX/bin
#cp "$PREFIX/bin/RapGreen.jar "$outdir/"
#chmod 0755 "${PREFIX}/bin/RapGreen.jar"

#ln -s "$outdir/rapgreen" "$PREFIX/bin"
