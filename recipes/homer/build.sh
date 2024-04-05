#! /bin/bash

outdir=$PREFIX/share/$PKG_NAME
mkdir -p $outdir
mkdir -p $outdir/bin
mkdir -p $PREFIX/bin
chmod +x configureHomer.pl
cp configureHomer.pl $outdir/

ln -s ${CC} $BUILD_PREFIX/bin/gcc
ln -s ${CXX} $BUILD_PREFIX/bin/g++

( cd $outdir && perl configureHomer.pl -keepScript -install )

ls -1 $outdir/bin/ | grep -v old | sed -e "s/\*/ \\\/g" | while read id;
do
    chmod +x $outdir/bin/$id;
    ln -s $outdir/bin/$id $PREFIX/bin/$id;
done
