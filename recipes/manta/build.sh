#!/bin/bash
set -eu

if [[ $(arch) == "aarch64" ]]; then
    mkdir build ; cd build
    ls $PREFIX
    find $PPREFIX -name '*boost*'
    BOOST_ROOT=${PREFIX} ../configure --prefix=${PREFIX}
    make
    make install
    
else
    outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
    mkdir -p $outdir
    mkdir -p $PREFIX/bin

    cp -r * $outdir
    rm -rf $outdir/share/demo
    sed -i.bak 's/__file__/os.path.realpath(__file__)/' $outdir/bin/configManta.py
    ln -s $outdir/bin/configManta.py $PREFIX/bin
    ln -s $outdir/libexec/convertInversion.py $PREFIX/bin
    ln -s $outdir/libexec/denovo_scoring.py $PREFIX/bin
fi
