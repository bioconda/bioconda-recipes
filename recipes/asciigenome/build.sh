#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp ASCIIGenome.jar $outdir
echo '#!/bin/sh' > $outdir/ASCIIGenome
echo exec java -Xmx8000m -jar $outdir/ASCIIGenome.jar '"$@"' >> $outdir/ASCIIGenome
chmod a+x $outdir/ASCIIGenome
ln -s $outdir/ASCIIGenome $PREFIX/bin
