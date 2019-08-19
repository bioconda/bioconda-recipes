#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/bin/bin
echo $PREFIX

cp -r * $outdir/
cd $outdir
mkdir build
cd build
cmake ..
make
cd ..
cd src
python setup.py build_ext --inplace

ln -s $outdir/TIDDIT.py $PREFIX/bin/tiddit

chmod 0755 ${PREFIX}/bin/tiddit
