#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -r data $outdir
sed -i 's/__file__/os.path.realpath(__file__)/' OptiTypePipeline.py
sed -i '1i#!/opt/anaconda1anaconda2anaconda3/bin/python' OptiTypePipeline.py
sed -i '/^from __future__/a import os\nthis_dir = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(os.path.realpath(__file__))))\nimport sys\nsys.path.append(this_dir)' OptiTypePipeline.py
chmod a+x OptiTypePipeline.py
cp *.py $outdir
cp config* $outdir
ln -s $outdir/OptiTypePipeline.py $PREFIX/bin
