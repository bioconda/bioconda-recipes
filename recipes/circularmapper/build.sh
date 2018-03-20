#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/

#Download JAR file for RealignSAMFile
curl -o realign-1.93.4.jar https://github.com/apeltzer/CircularMapper/releases/download/v1.93.4/realign-1.93.4.jar
sha256sum realign-1.93.4.jar | grep 1fe5ec912b012dc0dcd13f280834bcc0b3f8a62a5518b6eed3b126ea05293670
cp realign-1.93.4.jar $outdir/

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

