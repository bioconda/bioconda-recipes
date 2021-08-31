outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $outdir/bin
mkdir -p $outdir/lib
mkdir -p $PREFIX/bin

unamestr=`uname`
if [ "$unamestr" == 'Linux' ];
then
    cp -a lib/. $outdir/lib
    cp -r bin/sirius $outdir/bin/sirius
    chmod +x $outdir/bin/sirius
    ln -s $outdir/bin/sirius $PREFIX/bin
elif [ "$unamestr" == 'Darwin' ];
then
    cp -r Contents/* $outdir
    ln -s $outdir/MacOS/sirius $PREFIX/bin
fi