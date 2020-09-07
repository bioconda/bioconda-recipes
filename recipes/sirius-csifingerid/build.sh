outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $outdir/bin
mkdir -p $outdir/lib
mkdir -p $PREFIX/bin

cp -a lib/. $outdir/lib
cp -r bin/sirius $outdir/bin/sirius
chmod +x $outdir/bin/sirius
ln -s $outdir/bin/sirius $PREFIX/bin
