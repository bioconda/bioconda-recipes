#! /bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $outdir/bin
mkdir -p $PREFIX/bin
chmod +x configureHomer.pl
cp configureHomer.pl $outdir/

( cd $outdir && perl configureHomer.pl -install )

ls -1 $outdir/bin/ | grep -v old | sed -e "s/\*/ \\\/g" | while read id;
do
    chmod +x $outdir/bin/$id;
    ln -s $outdir/bin/$id $PREFIX/bin/$id;
done
