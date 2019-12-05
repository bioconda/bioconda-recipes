#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
echo $PREFIX

mkdir build
cd build
cmake ..
make
cp ../bin/TIDDIT $PREFIX/bin
cp -r ../lib/bamtools $PREFIX/lib  # Yes, this vendors bamtools :(
cd ../src
python -m pip install . --ignore-installed --no-deps -vv
cd ../build
make DESTDIR=${PREFIX} install
cd ..

# Clean up bamtools
rm -rf $PREFIX/usr

mv TIDDIT.py ${PREFIX}/bin
ln -s ${PREFIX}/bin/TIDDIT.py $PREFIX/bin/tiddit 
chmod a+x ${PREFIX}/bin/*
