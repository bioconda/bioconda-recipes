#!/bin/bash
set -eu -o pipefail
echo -e "Running in directory '$(pwd)'"
ls -l
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
#mv "download_file?file_path=de%2Fisas%2Flipidomics%2Fjgoslin-cli%2F1.1.2%2Fjgoslin-cli-1.1.2.jar" "$PKG_NAME-cli-$PKG_VERSION.jar"
zipname="$PKG_NAME-cli-$PKG_VERSION-bin.zip"
mv "download_file?file_path=de%2Fisas%2Flipidomics%2Fjgoslin-cli%2F1.1.2%2Fjgoslin-cli-1.1.2-bin.zip" "$zipname"
unzip "$zipname"
ls -l
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/jgoslin.py $outdir/jgoslin
ls -l $outdir
ln -s $outdir/jgoslin $PREFIX/bin
echo "Contents of '$outdir'"
ls -l
chmod 0755 "${PREFIX}/bin/jgoslin"
