#!/bin/bash
set -eu
# Only installs the parts for running THetA not pre-prearation
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp python/* $outdir

# bnpy dependency
wget -O bnpy-dev.zip https://bitbucket.org/michaelchughes/bnpy-dev/get/590663f97f93.zip
unzip bnpy-dev.zip
mv michaelchughes-bnpy-dev-590663f97f93/bnpy $outdir

maincmd=$outdir/RunTHetA.py
sed -i.bak '1i#!/opt/anaconda1anaconda2anaconda3/bin/python' $maincmd
sed -i.bak '2iimport os\nthis_dir = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(os.path.realpath(__file__))))\nimport sys\nsys.path.append(this_dir)' $maincmd
chmod a+x $maincmd
ln -s $maincmd $PREFIX/bin
