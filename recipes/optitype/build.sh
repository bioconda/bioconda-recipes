#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -r data $outdir
sed -i '1i#!/opt/anaconda1anaconda2anaconda3/bin/python' OptiTypePipeline.py
sed -i '3iimport os\nthis_dir = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))\nimport sys\nsys.path.append(this_dir)' OptiTypePipeline.py
chmod a+x OptiTypePipeline.py
cp *.py $outdir
cp config* $outdir
ln -s $outdir/OptiTypePipeline.py $PREFIX/bin
