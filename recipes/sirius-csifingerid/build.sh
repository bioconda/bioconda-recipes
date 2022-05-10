outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM


if [[ ${target_platform} =~ linux.* ]] ; then
    mkdir -p $outdir
    mkdir -p $PREFIX/bin

    cp -a ./* $outdir/
    chmod +x $outdir/bin/sirius
    # protecting libs from being modified by conda-build
    tar czf $outdir/lib.tgz -C $outdir/lib .
    rm -r $outdir/lib

    ln -s $outdir/bin/sirius $PREFIX/bin
    ln -s $outdir/bin/sirius-gui $PREFIX/bin

elif [[ ${target_platform} =~ osx.* ]] ; then
     mkdir -p $outdir/Contents
     mkdir -p $PREFIX/bin

     cp -a Contents/. $outdir/Contents
     chmod +x $outdir/Contents/MacOS/sirius

     # protecting libs from being modified by conda-build
     tar czf $outdir/Contents/runtime.tgz -C $outdir/Contents/runtime .
     tar czf $outdir/Contents/native.tgz -C $outdir/Contents/native .
     rm -r $outdir/Contents/runtime
     rm -r $outdir/Contents/native

     ln -s $outdir/Contents/MacOS/sirius $PREFIX/bin
     ln -s $outdir/Contents/MacOS/sirius-gui $PREFIX/bin
fi