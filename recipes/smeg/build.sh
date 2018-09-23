
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cd $SRC_DIR

cp -a . /$outdir/
chmod +x $outdir/smeg
chmod +x $outdir/uniqueSNPmultithreading
chmod +x $outdir/pileupParser

ln -s $outdir/smeg $PREFIX/bin/smeg
