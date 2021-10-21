outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

if [[ ${target_platform} =~ linux.* ]] ; then
    mkdir -p $outdir
    mkdir -p $PREFIX/bin

    cp -a ./* $outdir/
    chmod +x $outdir/bin/sirius
    ln -s $outdir/bin/sirius $PREFIX/bin
elif [[ ${target_platform} =~ osx.* ]] ; then
     mkdir -p $outdir/Contents
     mkdir -p $PREFIX/bin

     cp -a Contents/. $outdir/Contents
     chmod +x $outdir/Contents/MacOS/sirius
     ln -s $outdir/Contents/MacOS/sirius $PREFIX/bin
fi