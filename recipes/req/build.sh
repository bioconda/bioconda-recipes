#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/

mv src/REQ.java .
javac REQ.java
echo Main-Class: REQ > MANIFEST.MF
jar -cmvf MANIFEST.MF REQ.jar REQ.class
rm MANIFEST.MF REQ.class
cp REQ.jar $outdir/REQ.jar

cp $RECIPE_DIR/REQ.sh $outdir/REQ
ls -l $outdir
ln -s $outdir/REQ $PREFIX/bin
chmod 0755 "${PREFIX}/bin/REQ"
