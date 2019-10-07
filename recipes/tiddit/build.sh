#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
echo $PREFIX

mkdir build
cd build
cmake ..
make
make DESTDIR=${PREFIX} install
cd $outdir/src
python setup.py build_ext --inplace

ln -s $outdir/TIDDIT.py $PREFIX/bin/tiddit

chmod 0755 ${PREFIX}/bin/tiddit
