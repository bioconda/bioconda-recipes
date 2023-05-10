#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/umicollapse.py $outdir/umicollapse
ln -s $outdir/umicollapse $PREFIX/bin
curl -O -L https://repo1.maven.org/maven2/com/github/samtools/htsjdk/2.19.0/htsjdk-2.19.0.jar
curl -O -L https://repo1.maven.org/maven2/org/xerial/snappy/snappy-java/1.1.7.3/snappy-java-1.1.7.3.jar
mkdir -p $PREFIX/bin/lib
mv htsjdk-2.19.0.jar $PREFIX/bin/lib
mv snappy-java-1.1.7.3.jar $PREFIX/bin/lib
chmod 0755 "${PREFIX}/bin/umicollapse"