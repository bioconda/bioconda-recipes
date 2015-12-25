#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -r bin $outdir
cp -r lib $outdir
# replace transrate with fixed wrapper
#rm transrate
#wget -qO- https://gist.githubusercontent.com/roryk/318b347128bf5df8fee5/raw/63ad7b983dd7083cb8ce513aa3ead259295bd376/gistfile1.txt > transrate
#chmod ug+x  transrate
cp transrate $outdir/.
ln -s $outdir/transrate $PREFIX/bin/transrate
