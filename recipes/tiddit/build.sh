#!/bin/bash

mkdir build
cd build 
cmake .. 
make 
cd ..
cd src
python setup.py build_ext --inplace

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/ 
cp ../TIDDIT.py $outdir/
ls -l $outdir
ln -s $outdir/TIDDIT.py $PREFIX/bin/tiddit
chmod 0755 ${PREFIX}/bin/tiddit