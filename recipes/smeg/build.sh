
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cd $SRC_DIR

cp -a . /$outdir/
chmod +x $outdir/smeg
chmod +x $outdir/uniqueSNPmultithreading
chmod +x $outdir/pileupParser

ln -s $outdir/smeg $PREFIX/bin/smeg

cd $outdir
wget https://github.com/PathoScope/PathoScope/archive/v2.0.6.tar.gz
tar xvf v2.0.6.tar.gz
cd PathoScope-2.0.6/
python2.7 setup.py install

