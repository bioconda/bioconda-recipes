#!/bin/bash

outdir="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p $outdir
cp -R * $outdir

make -C $outdir/graph_simplification/nwalign/

mkdir -p $PREFIX/bin
ln -s  $outdir/MinYS.py  ${PREFIX}/bin/
ln -s $outdir/graph_simplification/enumerate_paths.py  ${PREFIX}/bin/
ln -s $outdir/graph_simplification/filter_components.py  ${PREFIX}/bin/
ln -s $outdir/graph_simplification/graph_simplification.py  ${PREFIX}/bin/

