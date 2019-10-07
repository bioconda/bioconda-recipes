#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
echo $PREFIX

mkdir build
cd build
cmake ..
make
cd ../src
python setup.py build_ext --inplace
cd ../build
make DESTDIR=${PREFIX} install

ln -s $outdir/TIDDIT.py $PREFIX/bin/tiddit

chmod 0755 ${PREFIX}/bin/tiddit
