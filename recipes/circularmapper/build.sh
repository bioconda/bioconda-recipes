#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/

#Download JAR file for RealignSAMFile
cd $outdir/
wget https://github.com/apeltzer/CircularMapper/releases/download/v1.93.5/realign-1.93.5.jar --no-check-certificate 
sha256sum realign-1.93.5.jar | grep 0b43fddeb3ef9b34f9bff64075be46ee59905f183664007ae437225f9f69f762

#Install CircularGenerator
cp $RECIPE_DIR/circulargenerator.py $outdir/circulargenerator 
ls -l $outdir
ln -s $outdir/circulargenerator $PREFIX/bin
chmod 0755 ${PREFIX}/bin/circulargenerator
#Install RealignSAMFile
cp $RECIPE_DIR/realignsamfile.py $outdir/realignsamfile 
ls -l $outdir
ln -s $outdir/realignsamfile $PREFIX/bin
chmod 0755 ${PREFIX}/bin/realignsamfile

